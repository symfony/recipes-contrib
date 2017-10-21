<?php

use App\Controller\User\{ConfirmAccountController, ConfirmEmailController, ForgotPasswordController, LoginController, MyAccountController, RegisterController, ResetPasswordController};
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return function (RoutingConfigurator $routes) {
    $routes
        ->add('login', '/login')
            ->controller(LoginController::class)
        ->add('logout', '/logout')
        ->add('register', '/register')
            ->controller(RegisterController::class)
        ->add('confirm_account', '/confirm-account/{token}')
            ->controller(ConfirmAccountController::class)
        ->add('confirm_email', '/confirm-email/{token}')
            ->controller(ConfirmEmailController::class)
        ->add('forgot_password', '/forgot-password')
            ->controller(ForgotPasswordController::class)
        ->add('reset_password', '/reset-password/{token}')
            ->controller(ResetPasswordController::class)
        ->add('my_account', '/my-accounts')
            ->controller(MyAccountController::class)
    ;
};
