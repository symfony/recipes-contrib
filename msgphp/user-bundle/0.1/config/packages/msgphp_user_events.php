<?php

use App\EventSubscriber\{SendAccountConfirmationUrlToPendingUser, SendEmailConfirmationUrlToUser, SendPasswordResetUrlToUser};
use MsgPhp\User\Event\{PendingUserCreatedEvent, UserPasswordRequestedEvent, UserPendingPrimaryEmailSetEvent, UserSecondaryEmailAddedEvent};
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $container) {
    $container->services()
        ->defaults()
            ->autowire()
            ->public()
        ->set(SendAccountConfirmationUrlToPendingUser::class)
            ->tag('event_subscriber', ['subscribes_to' => PendingUserCreatedEvent::class])
        ->set(SendEmailConfirmationUrlToUser::class)
            ->tag('event_subscriber', ['subscribes_to' => UserSecondaryEmailAddedEvent::class])
            ->tag('event_subscriber', ['subscribes_to' => UserPendingPrimaryEmailSetEvent::class])
        ->set(SendPasswordResetUrlToUser::class)
            ->tag('event_subscriber', ['subscribes_to' => UserPasswordRequestedEvent::class])
    ;
};
