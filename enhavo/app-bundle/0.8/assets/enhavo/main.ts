import Application from "@enhavo/app/Main/MainApplication";
import ViewRegistryPackage from "./registry/view";
import MenuRegistryPackage from "./registry/menu";

Application.getViewRegistry().registerPackage(new ViewRegistryPackage(Application));
Application.getMenuRegistry().registerPackage(new MenuRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/app/Main/Components/MainComponent.vue"));