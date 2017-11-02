<?php

namespace App\DataFixtures\ORM;

use App\Entity\Eav\Attribute;
use App\Entity\User\User;
use App\Entity\User\UserAttributeValue;
use App\Entity\User\UserRole;
use App\Security\UserRoleProvider;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\Persistence\ObjectManager;
use MsgPhp\Eav\Infra\Uuid\AttributeId;
use MsgPhp\Eav\Infra\Uuid\AttributeValueId;
use MsgPhp\User\Infra\Security\SecurityUser;
use MsgPhp\User\Infra\Uuid\UserId;
use Symfony\Component\Security\Core\Encoder\EncoderFactoryInterface;

final class Users extends Fixture
{
    private const PASSWORD = 'pass';

    public function load(ObjectManager $manager)
    {
        $user = $this->createUser('user@domain.dev');
        $user->enable();
        $manager->persist($user);
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $boolAttr = new Attribute(new AttributeId()), true));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $boolAttr, false));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $boolAttr, null));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $intAttr = new Attribute(new AttributeId()), 123));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $intAttr, -123));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $floatAttr = new Attribute(new AttributeId()), 123.1223456789));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $floatAttr, -0.123));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $stringAttr = new Attribute(new AttributeId()), 'text'));
        $manager->persist(new UserAttributeValue(new AttributeValueId(), $user, $dateTimeAttr = new Attribute(new AttributeId()), new \DateTime()));

        $user = $this->createUser('user+disabled@domain.dev');
        $manager->persist($user);

        $user = $this->createUser('user+admin@domain.dev');
        $user->enable();
        $manager->persist($user);
        $manager->persist(new UserRole($user, UserRoleProvider::ROLE_ADMIN));

        $user = $this->createUser('user+admin+disabled@domain.dev');
        $manager->persist($user);
        $manager->persist(new UserRole($user, UserRoleProvider::ROLE_ADMIN));

        $manager->flush();
    }

    private function createUser(string $email, string $password = self::PASSWORD): User
    {
        /** @var EncoderFactoryInterface $encoder */
        $encoder = $this->container->get('security.encoder_factory');

        return new User(new UserId(), $email, $encoder->getEncoder(SecurityUser::class)->encodePassword($password, null));
    }
}
