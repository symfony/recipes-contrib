<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Softspring\UserBundle\Entity\ConfirmableTrait;
use Softspring\UserBundle\Entity\NameSurnameTrait;
use Softspring\UserBundle\Entity\PasswordRequestTrait;
use Softspring\UserBundle\Entity\RolesAdminTrait;
use Softspring\UserBundle\Entity\UserHasLocalePreferenceTrait;
use Softspring\UserBundle\Entity\UserIdentifierEmailTrait;
use Softspring\UserBundle\Entity\UserLastLoginTrait;
use Softspring\UserBundle\Entity\UserPasswordTrait;
use Softspring\UserBundle\Model\ConfirmableInterface;
use Softspring\UserBundle\Model\NameSurnameInterface;
use Softspring\UserBundle\Model\PasswordRequestInterface;
use Softspring\UserBundle\Model\RolesAdminInterface;
use Softspring\UserBundle\Model\User as UserModel;
use Softspring\UserBundle\Model\UserAvatarInterface;
use Softspring\UserBundle\Model\UserAvatarTrait;
use Softspring\UserBundle\Model\UserHasLocalePreferenceInterface;
use Softspring\UserBundle\Model\UserIdentifierEmailInterface;
use Softspring\UserBundle\Model\UserLastLoginInterface;
use Softspring\UserBundle\Model\UserPasswordInterface;

/**
 * @ORM\Entity()
 * @ORM\HasLifecycleCallbacks()
 */
#[ORM\Entity]
#[ORM\HasLifecycleCallbacks]
class User extends UserModel implements NameSurnameInterface, UserPasswordInterface, PasswordRequestInterface, UserIdentifierEmailInterface, UserAvatarInterface, ConfirmableInterface, RolesAdminInterface, UserLastLoginInterface, UserHasLocalePreferenceInterface
{
    use UserIdentifierEmailTrait;
    use NameSurnameTrait;
    use UserPasswordTrait;
    use PasswordRequestTrait;
    use UserAvatarTrait;
    use ConfirmableTrait;
    use RolesAdminTrait;
    use UserLastLoginTrait;
    use UserHasLocalePreferenceTrait;

    /**
     * @ORM\Id
     * @ORM\Column(length=13, options={"fixed": true})
     * @ORM\GeneratedValue(strategy="NONE")
     */
     #[ORM\Id]
     #[ORM\Column(length: 13, options: ['fixed' => true])]
     #[ORM\GeneratedValue(strategy: 'NONE')]
     protected ?string $id = null;

     public function getId(): ?string
     {
         return $this->id;
     }

     /**
      * @ORM\PrePersist()
      */
     #[ORM\PrePersist]
     public function _generateId(): void
     {
         $this->id = uniqid();
     }

    public function getDisplayName(): string
    {
        return $this->getName().' '.$this->getSurname();
    }
}
