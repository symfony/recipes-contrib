#!/usr/bin/env bash
# App container pause/resume around restore, plus post-restore cache:clear hints.
# Sourced by deploy/sync-runtime.sh. Safe to source from tests.

stop_app_containers() {
  STOPPED_APP=()
  local svc line
  local -a running=()
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN would stop web/worker/scheduler if running"
    return
  fi
  while IFS= read -r line; do
    [[ -n "$line" ]] && running+=("$line")
  done < <("${COMPOSE[@]}" --profile worker --profile scheduler ps --status running --format '{{.Service}}' 2>/dev/null || true)
  for svc in web worker scheduler; do
    local r
    for r in "${running[@]+"${running[@]}"}"; do
      if [[ "$r" == "$svc" ]]; then
        log "Stopping ${svc} for restore"
        "${COMPOSE[@]}" stop "$svc" >/dev/null || "${COMPOSE[@]}" --profile "$svc" stop "$svc" >/dev/null || true
        STOPPED_APP+=("$svc")
      fi
    done
  done
}

start_stopped_app() {
  local svc
  if [[ ${#STOPPED_APP[@]} -eq 0 ]]; then
    return
  fi
  for svc in "${STOPPED_APP[@]}"; do
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN would start ${svc}"
      continue
    fi
    log "Starting ${svc}"
    case "$svc" in
      web) "${COMPOSE[@]}" up -d --no-build web >/dev/null ;;
      worker) "${COMPOSE[@]}" --profile worker up -d --no-build worker >/dev/null || true ;;
      scheduler) "${COMPOSE[@]}" --profile scheduler up -d --no-build scheduler >/dev/null || true ;;
    esac
  done
}

post_restore_hints() {
  local target="${SYNC_APP_URL:-${APP_URL:-}}"
  if sync_rewrite_requested; then
    log "Sales-channel domains: opt-in rewrite was requested (see SYNC_REWRITE_*). Payment/shipping webhooks may still need manual review."
  else
    log "Sales-channel domains were not rewritten (default). Set SYNC_REWRITE_APP_URL=https://staging.example.com (or SYNC_REWRITE_URL_MAP) on a non-live consumer to rewrite sales_channel_domain after restore."
    if [[ -n "$target" ]]; then
      log "This shop APP_URL / SYNC_APP_URL=${target} — destination storefront URL if you rewrite manually."
    fi
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN would try cache:clear (non-fatal) and optional SYNC_POST_RESTORE_CMD"
    return
  fi
  if [[ -n "${IMAGE:-}" ]]; then
    log "Trying cache:clear (non-fatal if the image/console is unavailable)"
    if ! "${COMPOSE[@]}" run --rm --pull never --entrypoint php web bin/console cache:clear; then
      log "cache:clear skipped or failed — not fatal"
    fi
  fi
  if [[ -n "${SYNC_POST_RESTORE_CMD:-}" ]]; then
    log "Running SYNC_POST_RESTORE_CMD (non-fatal)"
    if ! bash -lc "$SYNC_POST_RESTORE_CMD"; then
      log "SYNC_POST_RESTORE_CMD failed — not fatal"
    fi
  fi
}
