import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppModalRegistryPackage from "@enhavo/app/Modal/ModalRegistryPackage";

export default class ModalRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppModalRegistryPackage(application));
    }
}