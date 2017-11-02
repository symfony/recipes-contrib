<?php

namespace App\Form\User;

use MsgPhp\User\Infra\Validator\ExistingEmail;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\EmailType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Validator\Constraints\NotBlank;

final class ForgotPasswordType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('email', EmailType::class, [
            'constraints' => [new NotBlank(), new ExistingEmail()],
        ]);
    }
}
