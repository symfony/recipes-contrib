<?php
declare(strict_types=1);

namespace App\Security\Providers;

use EonX\EasySecurity\RolesProviders\AbstractInMemoryRolesProvider;

final class InMemoryRolesProvider extends AbstractInMemoryRolesProvider
{
    /**
     * @return \EonX\EasySecurity\Interfaces\RoleInterface[]
     */
    protected function initRoles(): array
    {
        return [
            // Define your roles/permissions mapping here...
        ];
    }
}
