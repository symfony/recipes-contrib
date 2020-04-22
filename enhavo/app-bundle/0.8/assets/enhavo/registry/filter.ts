import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppFilterRegistryPackage from "@enhavo/app/Grid/Filter/FilterRegistryPackage";

export default class FilterRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppFilterRegistryPackage(application));
    }
}