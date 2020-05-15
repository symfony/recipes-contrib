<?php

declare(strict_types=1);

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use Doctrine\ORM\Mapping as ORM;
use Silverback\ApiComponentsBundle\Entity\User\AbstractUser;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Mapping\ClassMetadata;

/**
 * @author Daniel West <daniel@silverback.is>
 * @ApiResource(
 *     collectionOperations={
 *         "get"={"security"="is_granted('ROLE_SUPER_ADMIN')"}
 *     },
 *     itemOperations={
 *         "get"={"security"="is_granted('ROLE_SUPER_ADMIN') or object == user"},
 *         "put"={"security"="is_granted('ROLE_SUPER_ADMIN') or object == user"},
 *         "patch"={"security"="is_granted('ROLE_SUPER_ADMIN') or object == user"},
 *         "delete"={"security"="is_granted('ROLE_SUPER_ADMIN')"}
 *     }
 * )
 * @ORM\Entity
 * @ORM\Table(name="`user`")
 */
class User extends AbstractUser
{
    public static function loadValidatorMetadata(ClassMetadata $metadata): void
    {
        $metadata->addPropertyConstraint('username', new Assert\Email([
            'message' => 'Please enter a valid email address.',
        ]));
    }

    public function __construct(
        string $username = '',
        string $emailAddress = '',
        bool $emailAddressVerified = false,
        array $roles = ['ROLE_USER'],
        string $password = '',
        bool $enabled = true
    ) {
        parent::__construct($username, $emailAddress, $emailAddressVerified, $roles, $password, $enabled);
        $this->emailAddress = $this->username;
    }

    public function setUsername(?string $username): self
    {
        parent::setUsername($username);
        $this->setEmailAddress($username);
        return $this;
    }
}
