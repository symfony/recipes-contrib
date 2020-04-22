import Application from "@enhavo/app/Preview/PreviewApplication";
import ActionRegistryPackage from "./registry/action";

Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/app/Preview/Components/ApplicationComponent.vue"));