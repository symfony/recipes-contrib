<?php

namespace App\EventSubscriber;

use MsgPhp\User\Entity\UserSecondaryEmail;
use MsgPhp\User\Event\UserSecondaryEmailAddedEvent;
use Twig\Environment;

final class SendEmailConfirmationUrlToUser
{
    private $mailer;
    private $twig;

    public function __construct(\Swift_Mailer $mailer, Environment $twig)
    {
        $this->mailer = $mailer;
        $this->twig = $twig;
    }

    public function __invoke(UserSecondaryEmailAddedEvent $event): void
    {
        if (!$event->userSecondaryEmail->getConfirmedAt()) {
            $this->notify($event->userSecondaryEmail);
        }
    }

    public function notify(UserSecondaryEmail $userSecondaryEmail): void
    {
        if ($userSecondaryEmail->getConfirmedAt()) {
            throw new \LogicException('Cannot notify a secondary user e-mail which is already confirmed.');
        }

        $params = ['userSecondaryEmail' => $userSecondaryEmail];
        $message = (new \Swift_Message('Confirm your e-mail at The App'))
            ->addTo($userSecondaryEmail->getEmail())
            ->setBody($this->twig->render('User/email/confirm_email.txt.twig', $params), 'plain/text')
            ->addPart($this->twig->render('User/email/confirm_email.html.twig', $params), 'text/html');

        $this->mailer->send($message);
    }
}
