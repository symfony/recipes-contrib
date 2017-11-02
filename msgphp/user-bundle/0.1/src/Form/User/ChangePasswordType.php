<?php

namespace App\Form\User;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\PasswordType;
use Symfony\Component\Form\Extension\Core\Type\RepeatedType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Security\Core\Validator\Constraints\UserPassword;
use Symfony\Component\Validator\Constraints\NotBlank;

final class ChangePasswordType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('currentPassword', PasswordType::class, [
            'constraints' => [new UserPassword()],
        ]);
        $builder->add('password', RepeatedType::class, [
            'type' => PasswordType::class,
            'constraints' => [new NotBlank()],
        ]);
    }
}
