import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppMenuRegistryPackage from "@enhavo/app/Menu/MenuRegistryPackage";

export default class MenuRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppMenuRegistryPackage(application));
    }
}