import Application from "@enhavo/media/ImageCropper/ImageCropperApplication";
import ActionRegistryPackage from "./registry/action";

Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/media/ImageCropper/Components/ImageCropperComponent.vue"));