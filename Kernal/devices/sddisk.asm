
    sendDisk: // Wyslanie wiadomosci

        ram 0x2112
            savea 0x0

        out ebx 0x0 // Wyslanie informacji
        out eax 0x1

        ret

    waitforansw:
        loopfirstx:
            ram 0x2112
                read ebx
                cmpa ebx 0xffff
                    jeq finloopfirstx
                    jmp loopfirstx

            finloopfirstx:
                savea 0x0

        ret

    diskrdy:
            call regcopyinter // Zapis rejestrow

            sot 0x0
                in eax 0x0
                ram 0x2115 // Pole zapisu
                save eax

            ram 0x2112
                savea 0xffff

            call regbackinter // Powrot do stanu pierwotnego
            ret

    initdisk:
            set eax 0x1 // init
            set ebx 0x0
                call sendDisk

                call waitforansw
            ret

        startdisk:
            ram 0x2111 // Wylaczenie obslugi komponentow poza sdcard
                savea 0xffff
            ret

        closedisk:
            ram 0x2111
                savea 0x0

            ret

        diskloader:
            call regcopy

            call startdisk
            call initdisk

            set eax 0x2 // Wybranie bloku
            set ebx 0x0
                 call sendDisk

            set edx 0x0
            set ecx 0x0

            set eax 0x3 // Otworzenie strumienia
            set ebx 0x0
                 call sendDisk

                 call waitforansw

            ram 0x2113
                savea 0x2800

            ram 0x2114
                savea 0x0

            diskloaderloopread:

                    set eax 0x5
                    set ebx 0x0
                         call sendDisk

                         call waitforansw

                    set edx 0x0
                    diskloaderloopreade: // Ladowanie symboli
                        set eax 0x7
                        set ebx 0x0
                            call sendDisk
                            call waitforansw

                            ram 0x2114
                                read eax
                                cmpa eax 0xffff
                                    jeq diskloaderlooprnparz
                                    savea 0xffff

                                ram 0x2115 // Przesuniecie
                                    read eax
                                    set ebx 0x7
                                        shl eax ebx
                                            res eax

                                ram 0x2113 // Wczytanie adresu
                                    read ebx
                                    uram ebx // Wczytanie komorki
                                        read ebx

                                save eax

                            jmp ediskloaderlooprnparz

                            diskloaderlooprnparz:
                            set eax 0x0
                                save eax

                            ram 0x2115 // Przesuniecie
                                read eax

                            ram 0x2113 // Wczytanie adresu
                                read ebx
                                uram ebx // Wczytanie komorki
                                    read ebx

                                eor eax ebx
                                save eax

                            ram 0x2113
                                read eax
                                inc eax
                                save eax
                            ediskloaderlooprnparz:

                        cmpa edx 0x7
                            jeq finishdiskloaderloopreade

                        inc edx
                        jmp diskloaderloopreade
                    finishdiskloaderloopreade:


                    cmpa ecx 0x3f
                        jeq finishdiskloaderloopread
                    inc ecx
                    jmp diskloaderloopread

            finishdiskloaderloopread:

            ram 0x2802
                read eax


            ram 0x1fe1
                save eax

            call closedisk
            call regback
            ret