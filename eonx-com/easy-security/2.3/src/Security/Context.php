<?php
declare(strict_types=1);

namespace App\Security;

use App\Security\Interfaces\ContextInterface;
use EonX\EasySecurity\Context as BaseContext;

/**
 * When migrating to PHP7.4 this interface will be used to override return type hint for this app.
 */
final class Context extends BaseContext implements ContextInterface
{
    // No body needed for now.
}
