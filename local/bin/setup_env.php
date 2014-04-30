<?php

$source = "/home/rik/git/environment/dotfiles/";
$destination = "/home/rik/tst/";

echo sprintf('Installing dotfiles from [%s] to [%s]' . PHP_EOL , $source, $destination);

$dot = new Dotfiles($source, $destination, false);
$dot->execute();

class Dotfiles {
    private $source;
    private $destination;
    private $overide_files;

    public function __construct($source, $destination, $overideFiles = false) {
        $this->source = $source;
        $this->destination = $destination;
        $this->overide_files = $overideFiles;
    }

    public function execute() {
        $this->iterateDir($this->source, $this->destination);
    }

    public function iterateDir($directory, $destination) {
        if (substr($directory, -1) != '/') {
            $directory .= '/';
        }

        if (substr($destination, -1) != '/') {
            $destination .= '/';
        }
           
        foreach (new DirectoryIterator($directory) as $fileInfo) {
            if($fileInfo->isDot()) {
                //  echo 'IsDot ' . $fileInfo->getFilename()  .PHP_EOL; 
                continue;
            }
            
            if ($fileInfo->isFile()) {
                $this->installFile($fileInfo, $destination);
            } else {
                $this->installDirectory($fileInfo, $destination);
            }
        }
    }

    public function installFile($fileInfo, $destination) {
        // Check if there is a target file
        $targetFile = $destination . $fileInfo->getFilename();
        
        if (file_exists($targetFile) && $this->overide_files === false) {
            // @todo implement
            echo sprintf('[warning] - File [%s] exists in target folder' . PHP_EOL, $fileInfo->getFilename());
        } else {
            echo sprintf('[info] - Linking [%s] to [%s]' . PHP_EOL, $fileInfo->getPathname(), $targetFile);
            shell_exec(sprintf(
              'ln -sf %s %s',
                $fileInfo->getPathname(),
               $targetFile
            ));
        }
    }

    public function installDirectory($fileInfo, $destination) {
        $targetDir = $destination . $fileInfo->getFilename();
        if (file_exists($targetDir)) {
            //echo sprintf('Directory [%s] exists' . PHP_EOL, $fileInfo->getFilename());
            echo sprintf('[info] - Iterating [%s]'  . PHP_EOL, $fileInfo->getPathname());            
            $this->iterateDir($fileInfo->getPathname(), $targetDir);
        } else {
            echo sprintf('Linking directory [%s] to [%s]' . PHP_EOL, $fileInfo->getPathname(), $targetDir);
            shell_exec(sprintf(
                'ln -fs %s %s',
                $fileInfo->getPathname(),
                $targetDir
            ));
        }
    }
}