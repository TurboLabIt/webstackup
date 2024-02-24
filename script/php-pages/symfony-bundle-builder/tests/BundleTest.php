<?php
/**
 * 🪄 Based on https://github.com/TurboLabIt/webstackup/blob/master/script/php-pages/tests/BundleTest.php
 *
 * 📚 Usage example (customize with your own):
 *
 * - MyVendorName   ➡ TurboLabIt
 * - MyPackageName  ➡ BaseCommand
 *
 * 💡 "Replace all" the above and you're done!
 *
 * Expected result:
 *
 * - filename           ➡ <Whatever>Test.php
 * - namespace          ➡ TurboLabIt\BaseCommandBundle\tests
 * - class              ➡ <Whatever>Test
 */
namespace MyVendorName\MyPackageNameBundle\tests;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use PHPUnit\Framework\Attributes\DataProvider;


class BundleTest extends WebTestCase
{
    public static function somethingProvider()
    {
        yield ['/aaa', '/bbb', '/ccc'];
    }


    #[DataProvider('somethingProvider')]
    public function testSomething(string $value)
    {
        $this->assertNotEmpty($value);
    }
}
