<?php

namespace App\Form\User;

use MsgPhp\User\Infra\Validator\UniqueEmail;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\EmailType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Security\Core\Validator\Constraints\UserPassword;
use Symfony\Component\Validator\Constraints\Email;
use Symfony\Component\Validator\Constraints\NotBlank;

final class ChangeEmailType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('currentPassword', PasswordType::class, [
            'constraints' => [new UserPassword()],
        ]);
        $builder->add('email', EmailType::class, [
            'constraints' => [new NotBlank(), new Email(), new UniqueEmail()],
        ]);
    }
}
