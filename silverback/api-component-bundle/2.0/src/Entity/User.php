<?php

declare(strict_types=1);

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use Doctrine\ORM\Mapping as ORM;
use Silverback\ApiComponentBundle\Entity\User\User as BaseUser;

/**
 * @author Daniel West <daniel@silverback.is>
 * @ApiResource(
 *     collectionOperations={
 *         "get"={"security"="is_granted('ROLE_SUPER_ADMIN')"},
 *         "post"={"validation_groups"={"Default", "postValidation"}}
 *     },
 *     itemOperations={
 *         "get"={"security"="is_granted('ROLE_SUPER_ADMIN') or object.owner == user"},
 *         "put"={"security"="is_granted('ROLE_SUPER_ADMIN') or object.owner == user"},
 *         "delete"={"security"="is_granted('ROLE_SUPER_ADMIN')"}
 *     }
 * )
 * @ORM\Entity
 */
class User extends BaseUser
{}
