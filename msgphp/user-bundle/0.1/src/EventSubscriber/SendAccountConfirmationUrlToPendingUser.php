<?php

namespace App\EventSubscriber;

use MsgPhp\User\Entity\PendingUser;
use MsgPhp\User\Event\PendingUserCreatedEvent;
use Twig\Environment;

final class SendAccountConfirmationUrlToPendingUser
{
    private $mailer;
    private $twig;

    public function __construct(\Swift_Mailer $mailer, Environment $twig)
    {
        $this->mailer = $mailer;
        $this->twig = $twig;
    }

    public function __invoke(PendingUserCreatedEvent $event): void
    {
        $this->notify($event->pendingUser);
    }

    public function notify(PendingUser $pendingUser): void
    {
        $params = ['pendingUser' => $pendingUser];
        $message = (new \Swift_Message('Confirm your account at The App'))
            ->addTo($pendingUser->getEmail())
            ->setBody($this->twig->render('User/email/confirm_account.txt.twig', $params), 'plain/text')
            ->addPart($this->twig->render('User/email/confirm_account.html.twig', $params), 'text/html');

        $this->mailer->send($message);
    }
}
