# 02-role.t --- test the parsefail role

use v6;
use Test;
use Grammar::Parsefail;

plan 3;

#| the grammar we'll be using
grammar TestingPF does Grammar::Parsefail {
    token dont_panic {
        foo <.typed_panic(X::Grammar)>
    }

    token not_sorry {
        bar <.typed_sorry(X::Grammar)>
        <.express_concerns>
    }

    token no_worry {
        baz <.typed_worry(X::Grammar)>
        <.express_concerns>
    }
}

#| A fake IO to capture error output
class FakeIO {
    has $.result;

    method print($str) {
        $!result ~= $str;
        True;
    }

    method CLEAR { $!result = "" }
}

my $fio = FakeIO.new;

{
    temp $*ERR = $fio;
    TestingPF.parse("foo", :rule<dont_panic>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Panic thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,2:
    Unspecified grammar error
    at <unspecified file>:1,2
    ------>|\e[32mfo\e[33m\c[EJECT SYMBOL]\e[31mo\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("bar", :rule<not_sorry>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Sorrow thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,2:
    Unspecified grammar error
    at <unspecified file>:1,2
    ------>|\e[32mba\e[33m\c[EJECT SYMBOL]\e[31mr\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("baz", :rule<no_worry>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Worry thrown properly";
    Potential difficulties:
        Unspecified grammar error
        at <unspecified file>:1,2
        ------>|\e[32mba\e[33m\c[EJECT SYMBOL]\e[31mz\e[0m

    The potential difficulties above may cause unexpected results, since they don't prevent the parser from completing.
    Fix or suppress the issues as needed to avoid any doubt in the results of parsing.
    END_ERR