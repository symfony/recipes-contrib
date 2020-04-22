import Application from "@enhavo/app/Index/IndexApplication";
import ActionRegistryPackage from "./registry/action";
Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/app/Index/Components/IndexComponent.vue"));