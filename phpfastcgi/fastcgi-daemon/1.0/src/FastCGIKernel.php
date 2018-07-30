<?php

namespace App;

use PHPFastCGI\FastCGIDaemon\Http\RequestInterface;
use PHPFastCGI\FastCGIDaemon\KernelInterface;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class FastCGIKernel implements KernelInterface
{
    private $kernel;

    public function __construct(HttpKernelInterface $kernel)
    {
        $this->kernel = $kernel;
    }

    public function handleRequest(RequestInterface $request)
    {
        $symfonyRequest = $request->getHttpFoundationRequest();

        $symfonyResponse = $this->kernel->handle($symfonyRequest);
        $this->kernel->terminate($symfonyRequest, $symfonyResponse);

        return $symfonyResponse;
    }
}
