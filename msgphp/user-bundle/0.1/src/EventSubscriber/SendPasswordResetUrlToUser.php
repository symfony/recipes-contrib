<?php

namespace App\EventSubscriber;

use MsgPhp\User\Entity\User;
use MsgPhp\User\Event\UserPasswordRequestedEvent;
use Twig\Environment;

final class SendPasswordResetUrlToUser
{
    private $mailer;
    private $twig;

    public function __construct(\Swift_Mailer $mailer, Environment $twig)
    {
        $this->mailer = $mailer;
        $this->twig = $twig;
    }

    public function __invoke(UserPasswordRequestedEvent $event): void
    {
        if (null !== $event->user->getPasswordResetToken()) {
            $this->notify($event->user);
        }
    }

    public function notify(User $user): void
    {
        if (null === $user->getPasswordResetToken()) {
            throw new \LogicException('Cannot notify a user without a password reset token.');
        }

        $params = ['user' => $user];
        $message = (new \Swift_Message('Reset your password at The App'))
            ->addTo($user->getEmail())
            ->setBody($this->twig->render('User/email/reset_password.txt.twig', $params), 'plain/text')
            ->addPart($this->twig->render('User/email/reset_password.html.twig', $params), 'text/html');

        $this->mailer->send($message);
    }
}
