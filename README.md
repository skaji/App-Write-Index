# NAME

App::Write::Index - write 02packages.details.txt for your local lib

# SYNOPSIS

    > write-index

# DESCRIPTION

`write-index` writes 02packages.details.txt for your local lib.
You should look at https://github.com/miyagawa/Carmel

# HOW TO USE

Let's assume you develop a project that has cpan module dependencies.

In you local machine, install deps to local/ dir, and git-commit index.txt:

    [local] $ cpanm -Llocal --installdeps .
    [local] $ write-index > index.txt
    [local] $ git add index.txt && git commit -m 'add index.txt'

Then deployment time, install deps from index.txt:

    [remote] $ cpanm --mirror-index $PWD/index.txt -Llocal --installdeps .

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
