import Application from "@enhavo/media/MediaLibrary/MediaLibraryApplication";
import ActionRegistryPackage from "../../../../app-bundle/0.9/assets/enhavo/registry/action";

Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/media/MediaLibrary/Components/ApplicationComponent.vue"));