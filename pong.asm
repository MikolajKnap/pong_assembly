.286
.model large
.stack 100h

.DATA
    ; ----------------------------------- pilka -------------------------------
    PILKA_X_START DW 160
    PILKA_Y_START DW 110
    PILKA_X DW 30d
    PILKA_Y DW 90d
    PILKA_ROZMIAR DW 04h
    PILKA_SZYBKOSC_X DW 5
    PILKA_SZYBKOSC_Y DW 2

    ; --------------------------------- PALETKI -----------------------------
    PALETKA_LEWA_X DW 10d
    PALETKA_LEWA_Y DW 80d
    PALETKA_PRAWA_X DW 305d
    PALETKA_PRAWA_Y DW 80d
    PALETKA_SZEROKOSC DW 4d
    PALETKA_WYSOKOSC DW 33d
    PALETKA_SZYBKOSC DW 10d

    ; ----------------------------- czas i okno 320x200 ---------------------
    RAMKA_CZASU DB 0

    OKNO_SZEROKOSC DW 320d
    OKNO_WYSOKOSC DW 200d
    OKNO_OGRANICZENIE DW 4d

    ; ------------------------------------- punkty --------------------------
    GRACZ1_PUNKTY DB 0
    GRACZ2_PUNKTY DB 0
    GRACZ1_PUNKTY_TEKST DB '0','$'
    GRACZ2_PUNKTY_TEKST DB '0','$'
    GRACZ1_WIN DB 'G1 wygrywa','$'
    GRACZ2_WIN DB "G2 wygrywa",'$'

.CODE
        ; ------------------------------------------ RYSUJ GRACZ1 WYGRAL PROC ------------------------------------
        RYSUJ_GRACZ1_WYGRAL PROC
        mov ah, 02h                 ; konfiguracja do ustawienia pozycji kursora
        mov bh, 00h                 ; konfiguracja do numeru strony
        mov dh, 20d                 ; wiersz
        mov dl, 40d                 ; kolumna
        int 10h                     ; wywolanie ustawien

        mov ah, 09h                 ; konfiguracja do wypisania tekstu na ekran
        lea dx, GRACZ1_WIN          ; dajemy do dx wskaznik do stringu z .data
        int 21h

        mov PALETKA_LEWA_Y, 80d     ; tutaj resetujemy pozycje paletek
        mov PALETKA_PRAWA_Y, 80d

        ret
    RYSUJ_GRACZ1_WYGRAL ENDP

    ; ------------------------------------------ RYSUJ GRACZ2 WYGRAL PROC ------------------------------------
    RYSUJ_GRACZ2_WYGRAL PROC
        mov ah, 02h                 ; konfiguracja do ustawienia pozycji kursora
        mov bh, 00h                 ; konfiguracja do numeru strony
        mov dh, 20d                 ; wiersz
        mov dl, 40d                 ; kolumna
        int 10h                     ; wywolanie ustawien

        mov ah, 09h                 ; konfiguracja do wypisania tekstu na ekran
        lea dx, GRACZ2_WIN ; dajemy do dx wskaznik do stringu z .data
        int 21h

        mov PALETKA_LEWA_Y, 80d     ; tutaj resetujemy pozycje paletek
        mov PALETKA_PRAWA_Y, 80d

        ret
    RYSUJ_GRACZ2_WYGRAL ENDP

    ; ------------------------------------------ WYWOLAJ DZWIEK1 PROC ------------------------------------
    WYWOLAJ_DZWIEK PROC
        MOV AL, 252         ; 2) Set up the write to the control word register.
        OUT 43h, AL         ; 2) Perform the write.
        MOV AX, 1600d       ; 2) Pull back the frequency from BX.
        OUT 42h, AL         ; 2) Send lower byte of the frequency.
        MOV AL, AH          ; 2) Load higher byte of the frequency.
        OUT 42h, AL         ; 2) Send the higher byte.
        IN AL, 61h          ; 3) Read the current keyboard controller status.
        OR AL, 03h          ; 3) Turn on 0 and 1 bit, enabling the PC speaker gate and the data transfer.
        OUT 61h, AL         ; 3) Save the new keyboard controller status.
        MOV CX, 01H
        MOV DX, 4240H
        MOV AH, 86H
        INT 15H
        IN AL, 61h          ; 5) Read the current keyboard controller status.
        AND AL, 0FCh        ; 5) Zero 0 and 1 bit, simply disabling the gate.
        OUT 61h, AL         ; 5) Write the new keyboard controller status.

        ret
    WYWOLAJ_DZWIEK ENDP

    ; ------------------------------------------ WYWOLAJ DZWIEK2 PROC ------------------------------------
    WYWOLAJ_DZWIEK2 PROC
        MOV AL, 252         ; 2) Set up the write to the control word register.
        OUT 43h, AL         ; 2) Perform the write.
        MOV AX, 3000d          ; 2) Pull back the frequency from BX.
        OUT 42h, AL         ; 2) Send lower byte of the frequency.
        MOV AL, AH          ; 2) Load higher byte of the frequency.
        OUT 42h, AL         ; 2) Send the higher byte.
        IN AL, 61h          ; 3) Read the current keyboard controller status.
        OR AL, 03h          ; 3) Turn on 0 and 1 bit, enabling the PC speaker gate and the data transfer.
        OUT 61h, AL         ; 3) Save the new keyboard controller status.
        MOV CX, 01H
        MOV DX, 4240H
        MOV AH, 86H
        INT 15H
        IN AL, 61h          ; 5) Read the current keyboard controller status.
        AND AL, 0FCh        ; 5) Zero 0 and 1 bit, simply disabling the gate.
        OUT 61h, AL         ; 5) Write the new keyboard controller status.

        ret
    WYWOLAJ_DZWIEK2 ENDP

    ; ------------------------------------------ RESETUJ PILKE PROC ------------------------------------
    RESET_PILKA PROC
        mov ax, PILKA_X_START
        mov PILKA_X, ax

        mov ax, PILKA_Y_START
        mov PILKA_Y, ax

        ret

    RESET_PILKA ENDP
    
    ; ---------------------------------------- CZYSC EKRAN PROC ------------------------------------------------
    CZYSC_EKRAN PROC
        
        ; ustawienie trybu video 13h
        MOV AH, 00h
        MOV AL, 13h
        INT 10h

        ; ustawianie koloru tla
        mov ah, 0Bh
        mov bh, 00h
        mov bl, 00h
        int 10h
    
        ret

    CZYSC_EKRAN ENDP

    ; ------------------------------------------------ RYSUJ PILKE PROC --------------------------------------------
    RYSUJ_PILKE PROC

        mov cx, PILKA_X                 ; pozycja poczatkowa X pilki
        mov dx, PILKA_Y                 ; pozycja poczatkowa Y pilki

        RYSUJ_PILKE_HORYZONTALNIE:
        mov ah, 0Ch                     ; ustawienie konfiguracji int 10h na rysowanie pikseli
        mov al, 0Fh                     ; wybranie bialego koloru
        mov bh, 00h                     ; wybranie strony 0
        int 10h                         ; rysowanie piksela

        inc cx                          ; zwiekszamy pozycje X o 1
        mov ax, cx                      ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PILKA_X                 ; odejmujemy od aktualnej pozycji X poczatkowa pozycje X
        cmp ax, PILKA_ROZMIAR           ; sprawdzamy czy nowa pozycja X jest wieksza niz wielkosc pilki
        jng  RYSUJ_PILKE_HORYZONTALNIE  ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; przejscie do nastepnej lini
        mov cx, PILKA_X                 ; wracamy z poczatkowa pozycja X pilki
        inc dx                          ; zwiekszamy wiersz o 1, czyli nastepna linia

        RYSUJ_PILKE_WERTYKALNIE:
        mov ax, dx                      ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PILKA_Y                 ; odejmujemy od aktualnej pozycji Y poczatkowa pozycje Y
        cmp ax, PILKA_ROZMIAR           ; sprawdzamy czy nowa pozycja Y jest wieksza niz wielkosc pilki
        jng RYSUJ_PILKE_HORYZONTALNIE   ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ret
        
    RYSUJ_PILKE ENDP

    GRACZ1_AKTUALIZUJ_WYNIK PROC
        xor ax, ax                      ; czyszczenie rejestru ax
        mov al, GRACZ1_PUNKTY           ; wpisanie do al wartosci punktow gracza 1
        add al, 30h                     ; konwertowanie ascii na liczbe
        mov [GRACZ1_PUNKTY_TEKST], al   ; wpisanie zmienionej liczby
        ret
    GRACZ1_AKTUALIZUJ_WYNIK ENDP

    GRACZ2_AKTUALIZUJ_WYNIK PROC
        xor ax, ax                      ; czyszczenie rejestru ax
        mov al, GRACZ2_PUNKTY           ; wpisanie do al wartosci punktow gracza 1
        add al, 30h                     ; konwertowanie ascii na liczbe
        mov [GRACZ2_PUNKTY_TEKST], al   ; wpisanie zmienionej liczby
        ret
    GRACZ2_AKTUALIZUJ_WYNIK ENDP

    ; ----------------------------------------------- PRZESUN PILKE PROC ---------------------------------------------
    PRZESUN_PILKE PROC
        
        ; przesuwanie pilki po X
        mov ax, PILKA_SZYBKOSC_X                ; zapisanie do ax predkosci pilki po osi X
        add PILKA_X, ax                         ; zwiekszenie pozycji pilki o predkosc osi X

        ; kolizja lewa scianka
        mov ax, OKNO_OGRANICZENIE
        cmp PILKA_X, ax                         ; porownujemy pozycje X pilki do lewej krawedzi
        JL GRACZ2_ZDOBYWA_PUNKT                 ; jesli mniejsza niz lewa krawedz to skaczemy

        ; kolizja prawa scianka
        mov ax, OKNO_SZEROKOSC                  ; zapis szerokosci okna do ax
        sub ax, PILKA_ROZMIAR
        sub ax, OKNO_OGRANICZENIE               ; zmniejszamy wartosc rozmiaru okna o wartosc rozmiaru pilki, w celu lepszej kolizji
        cmp PILKA_X, ax                         ; porownanie pozycji X pilki do prawej krawedzi
        jg GRACZ1_ZDOBYWA_PUNKT                 ; jesli wieksza niz prawa krawedz to skaczemy

        ; przesuwanie pilki po Y
        mov ax, PILKA_SZYBKOSC_Y                ; zapisanie do ax predkosci pilki po osi Y
        add PILKA_Y, ax                         ; zwiekszenie pozycji pilki o predkosc osi Y

        ; kolizja gorna scianka
        mov ax, OKNO_OGRANICZENIE
        cmp PILKA_Y, ax                         ; porownujemy pozycje Y pilki do lewej krawedzi
        JL ZAMIEN_PREDKOSC_Y                    ; jesli mniejsza niz gorna krawedz to skaczemy

        ; kolizja dolna scianka
        mov ax, OKNO_WYSOKOSC                   ; zapis wysokosci okna do ax
        sub ax, PILKA_ROZMIAR                   ; zmniejszamy wartosc rozmiaru okna o wartosc rozmiaru pilki, w celu lepszej kolizji
        sub ax, OKNO_OGRANICZENIE
        cmp PILKA_Y, ax                         ; porownanie pozycji Y pilki do prawej krawedzi
        jg ZAMIEN_PREDKOSC_Y                    ; jesli wieksza niz dolna krawedz to skaczemy
        
        jmp SPRAWDZ_KOLIZJE_PRAWA_PALETKA

        ZAMIEN_PREDKOSC_Y:
            NEG PILKA_SZYBKOSC_Y                ; zanegowanie predkosci pilki po y
            ret

        GRACZ2_ZDOBYWA_PUNKT:
            inc GRACZ2_PUNKTY
            call RESET_PILKA

            call GRACZ2_AKTUALIZUJ_WYNIK

            cmp GRACZ2_PUNKTY, 03h
            je KONIEC_GRY2
            

            ret

        GRACZ1_ZDOBYWA_PUNKT:
            inc GRACZ1_PUNKTY
            call RESET_PILKA

            call GRACZ1_AKTUALIZUJ_WYNIK

            cmp GRACZ1_PUNKTY, 03h
            je KONIEC_GRY1
            ret
        
        KONIEC_GRY2:
            mov GRACZ1_PUNKTY, 00h
            mov GRACZ2_PUNKTY, 00h
            call GRACZ1_AKTUALIZUJ_WYNIK
            call GRACZ2_AKTUALIZUJ_WYNIK
            call RYSUJ_GRACZ2_WYGRAL
            call WYWOLAJ_DZWIEK2
            call WYWOLAJ_DZWIEK
            call WYWOLAJ_DZWIEK2
            call WYWOLAJ_DZWIEK
            MOV CX, 98H
            MOV DX, 9680H
            MOV AH, 86H
            INT 15H
            ret

        KONIEC_GRY1:
            mov GRACZ1_PUNKTY, 00h
            mov GRACZ2_PUNKTY, 00h
            call GRACZ1_AKTUALIZUJ_WYNIK
            call GRACZ2_AKTUALIZUJ_WYNIK
            call RYSUJ_GRACZ1_WYGRAL
            call WYWOLAJ_DZWIEK2
            call WYWOLAJ_DZWIEK
            call WYWOLAJ_DZWIEK2
            call WYWOLAJ_DZWIEK
            MOV CX, 98H
            MOV DX, 9680H
            MOV AH, 86H
            INT 15H
            ret

        

        SPRAWDZ_KOLIZJE_PRAWA_PALETKA:
        ; --- sprawdzanie kolizji z prawa paletka ---
        ; wzor do kolizji:
        ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
        ; (PILKA_X + PILKA_ROZMIAR > PALETKA_PRAWA_X) &&
        ; (PILKA_X < PALETKA_PRAWA_X + PALETKA_SZEROKOSC) &&
        ; (PILKA_Y + PILKA_ROZMIAR > PALETKA_PRAWA_Y) &&
        ; (PILKA_Y < PALETKA_PRAWA_Y + PALETKA_WYSOKOSC)
        
        ; (PILKA_X + PILKA_ROZMIAR > PALETKA_PRAWA_X)
        mov ax, PILKA_X
        add ax, PILKA_ROZMIAR
        cmp ax, PALETKA_PRAWA_X
        jng SPRAWDZ_KOLIZJE_LEWA_PALETKA

        ; (PILKA_X < PALETKA_PRAWA_X + PALETKA_SZEROKOSC)
        mov ax, PALETKA_PRAWA_X
        add ax, PALETKA_SZEROKOSC
        cmp PILKA_X, ax
        jnl SPRAWDZ_KOLIZJE_LEWA_PALETKA

        ; (PILKA_Y + PILKA_ROZMIAR > PALETKA_PRAWA_Y)
        mov ax, PILKA_Y
        add ax, PILKA_ROZMIAR
        cmp ax, PALETKA_PRAWA_Y
        jng SPRAWDZ_KOLIZJE_LEWA_PALETKA

        ; (PILKA_Y < PALETKA_PRAWA_Y + PALETKA_WYSOKOSC)
        mov ax, PALETKA_PRAWA_Y
        add ax, PALETKA_WYSOKOSC
        cmp PILKA_Y, ax
        jnl SPRAWDZ_KOLIZJE_LEWA_PALETKA

        NEG PILKA_SZYBKOSC_X
        call WYWOLAJ_DZWIEK
        ret
        
        SPRAWDZ_KOLIZJE_LEWA_PALETKA:
            ; --- sprawdzanie kolizji z lewa paletka ---
            ; wzor do kolizji:
            ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2
            ; (PALETKA_LEWA_X + PALETKA_SZEROKOSC > PILKA_X) &&
            ; (PALETKA_LEWA_X < PILKA_X + PILKA_ROZMIAR) &&
            ; (PALETKA_LEWA_Y + PALETKA_WYSOKOSC > PILKA_Y) &&
            ; (PALETKA_LEWA_Y < PILKA_Y + PILKA_ROZMIAR)

            ; (PALETKA_LEWA_X + PALETKA_SZEROKOSC > PILKA_X)
            mov ax, PALETKA_LEWA_X
            add ax, PALETKA_SZEROKOSC
            cmp ax, PILKA_X
            jng BRAK_KOLIZJI

            ; (PALETKA_LEWA_X < PILKA_X + PILKA_ROZMIAR)
            mov ax, PILKA_X
            add ax, PILKA_ROZMIAR
            cmp PALETKA_LEWA_X, ax
            jnl BRAK_KOLIZJI

            ; (PALETKA_LEWA_Y + PALETKA_WYSOKOSC > PILKA_Y)
            mov ax, PALETKA_LEWA_Y
            add ax, PALETKA_WYSOKOSC
            cmp ax, PILKA_Y
            jng BRAK_KOLIZJI

            ; (PALETKA_LEWA_Y < PILKA_Y + PILKA_ROZMIAR)
            mov ax, PILKA_Y
            add ax, PILKA_ROZMIAR
            cmp PALETKA_LEWA_Y, ax
            jnl BRAK_KOLIZJI

        NEG PILKA_SZYBKOSC_X
        call WYWOLAJ_DZWIEK
        BRAK_KOLIZJI:
        ret

    PRZESUN_PILKE ENDP

    ; ----------------------------------------------- RYSUJ PALETKI PROC ---------------------------------------------
    RYSUJ_PALETKI PROC

        ; --- rysowanie lewej PALETKI ---
        mov cx, PALETKA_LEWA_X                     ; pozycja poczatkowa X PALETKI
        mov dx, PALETKA_LEWA_Y                     ; pozycja poczatkowa Y PALETKI

        RYSUJ_PALETKE_LEWA_HORYZONTALNIE:
            mov ah, 0Ch                            ; ustawienie konfiguracji int 10h na rysowanie pikseli
            mov al, 0Fh                            ; wybranie bialego koloru
            mov bh, 00h                            ; wybranie strony 0
            int 10h                                ; rysowanie piksela

            inc cx                                 ; zwiekszamy pozycje X o 1
            mov ax, cx                             ; przenosimy rejestr cx do ax - w celu obliczen
            sub ax, PALETKA_LEWA_X                 ; odejmujemy od aktualnej pozycji X poczatkowa pozycje X
            cmp ax, PALETKA_SZEROKOSC              ; sprawdzamy czy nowa pozycja X jest wieksza niz wielkosc PALETKI
            jng  RYSUJ_PALETKE_LEWA_HORYZONTALNIE  ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; przejscie do nastepnej lini
        mov cx, PALETKA_LEWA_X                     ; wracamy z poczatkowa pozycja X pilki
        inc dx                                     ; zwiekszamy wiersz o 1, czyli nastepna linia

        ; rysowanie PALETKI lewej wertykalnie
        mov ax, dx                                 ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PALETKA_LEWA_Y                     ; odejmujemy od aktualnej pozycji Y poczatkowa pozycje Y
        cmp ax, PALETKA_WYSOKOSC                   ; sprawdzamy czy nowa pozycja Y jest wieksza niz wysokosc PALETKI
        jng RYSUJ_PALETKE_LEWA_HORYZONTALNIE       ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; --- rysowanie prawej PALETKI ---
        mov cx, PALETKA_PRAWA_X                    ; pozycja poczatkowa X PALETKI
        mov dx, PALETKA_PRAWA_Y                    ; pozycja poczatkowa Y PALETKI

        RYSUJ_PALETKE_PRAWA_HORYZONTALNIE:
            mov ah, 0Ch                            ; ustawienie konfiguracji int 10h na rysowanie pikseli
            mov al, 0Fh                            ; wybranie bialego koloru
            mov bh, 00h                            ; wybranie strony 0
            int 10h                                ; rysowanie piksela

            inc cx                                 ; zwiekszamy pozycje X o 1
            mov ax, cx                             ; przenosimy rejestr cx do ax - w celu obliczen
            sub ax, PALETKA_PRAWA_X                ; odejmujemy od aktualnej pozycji X poczatkowa pozycje X
            cmp ax, PALETKA_SZEROKOSC              ; sprawdzamy czy nowa pozycja X jest wieksza niz wielkosc PALETKI
            jng  RYSUJ_PALETKE_PRAWA_HORYZONTALNIE ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; przejscie do nastepnej lini
        mov cx, PALETKA_PRAWA_X                    ; wracamy z poczatkowa pozycja X pilki
        inc dx                                     ; zwiekszamy wiersz o 1, czyli nastepna linia

        ; rysowanie PALETKI prawej wertykalnie
        mov ax, dx                                 ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PALETKA_PRAWA_Y                    ; odejmujemy od aktualnej pozycji Y poczatkowa pozycje Y
        cmp ax, PALETKA_WYSOKOSC                   ; sprawdzamy czy nowa pozycja Y jest wieksza niz wysokosc PALETKI
        jng RYSUJ_PALETKE_PRAWA_HORYZONTALNIE      ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ret

    RYSUJ_PALETKI ENDP
    
    ; ----------------------------------------------- PRZESUN PALETKI PROC ---------------------------------------------
    PRZESUN_PALETKI PROC
        ; sprawdzamy czy klawisz zostal wcisniety
        mov ah, 01h
        int 16h
        jz SPRAWDZ_PRAWA_PALETKE ; jesli nie to sprawdz druga paletke

        ; sprawdzamy ktory klawisz zostal wcisniety q (w gore) = 71 ascii, a (w dol) = 61 ascii
        mov ah, 00h
        int 16h

        cmp al, 71h ; q
        je PRZESUN_LEWA_PALETKE_W_GORE
        cmp al, 61h ; a
        je PRZESUN_LEWA_PALETKE_W_DOL
        jmp SPRAWDZ_PRAWA_PALETKE

        PRZESUN_LEWA_PALETKE_W_GORE:
            mov ax, PALETKA_SZYBKOSC
            sub PALETKA_LEWA_Y, ax          ; przesuwamy paletke w dol

            mov ax, OKNO_OGRANICZENIE
            cmp PALETKA_LEWA_Y, ax          ; sprawdzamy czy nie wyjechalismy poza ekran
            jl POPRAW_LEWA_PALETKE_GORA
            jmp SPRAWDZ_PRAWA_PALETKE

            POPRAW_LEWA_PALETKE_GORA:       ; zabezpieczenie zeby nie wyjechac paletka poza ekran
                mov ax, OKNO_OGRANICZENIE
                mov PALETKA_LEWA_Y, ax
                jmp SPRAWDZ_PRAWA_PALETKE

        PRZESUN_LEWA_PALETKE_W_DOL:
            mov ax, PALETKA_SZYBKOSC
            add PALETKA_LEWA_Y, ax          ; przesuwamy paletke w gore
            mov ax, OKNO_WYSOKOSC
            sub ax, OKNO_OGRANICZENIE
            sub ax, PALETKA_WYSOKOSC        ; sprawdzamy czy nie wyjechalismy poza ekran
            cmp PALETKA_LEWA_Y, ax
            jg POPRAW_LEWA_PALETKE_DOL
            jmp SPRAWDZ_PRAWA_PALETKE

            POPRAW_LEWA_PALETKE_DOL:        ; zabezpieczenie zeby nie wyjechac paletka poza ekran
                mov PALETKA_LEWA_Y, ax
                JMP SPRAWDZ_PRAWA_PALETKE
        
        ; analogicznie jak lewa
        SPRAWDZ_PRAWA_PALETKE:

            cmp al, 70h ; p
            je PRZESUN_PRAWA_PALETKE_W_GORE
            cmp al, 6Ch ; l
            je PRZESUN_PRAWA_PALETKE_W_DOL
            jmp WYJSCIE
            PRZESUN_PRAWA_PALETKE_W_GORE:
                mov ax, PALETKA_SZYBKOSC
                sub PALETKA_PRAWA_Y, ax

                mov ax, OKNO_OGRANICZENIE
                cmp PALETKA_PRAWA_Y, ax
                jl POPRAW_PRAWA_PALETKE_GORA
                jmp WYJSCIE

                POPRAW_PRAWA_PALETKE_GORA:
                    mov ax, OKNO_OGRANICZENIE
                    mov PALETKA_PRAWA_Y, ax
                    jmp WYJSCIE

            PRZESUN_PRAWA_PALETKE_W_DOL:
                mov ax, PALETKA_SZYBKOSC
                add PALETKA_PRAWA_Y, ax
                mov ax, OKNO_WYSOKOSC
                sub ax, OKNO_OGRANICZENIE
                sub ax, PALETKA_WYSOKOSC
                cmp PALETKA_PRAWA_Y, ax
                jg POPRAW_PRAWA_PALETKE_DOL
                jmp WYJSCIE

                POPRAW_PRAWA_PALETKE_DOL:
                    mov PALETKA_PRAWA_Y, ax
                    JMP WYJSCIE
        
        WYJSCIE:
        ret
    PRZESUN_PALETKI ENDP

    ; ------------------------------------------ RYSUJ PUNKTY PROC ----------------------------------------------
    RYSUJ_PUNKTY PROC
        mov ah, 02h                 ; konfiguracja do ustawienia pozycji kursora
        mov bh, 00h                 ; konfiguracja do numeru strony
        mov dh, 2d                  ; wiersz
        mov dl, 10d                 ; kolumna
        int 10h                     ; wywolanie ustawien

        mov ah, 09h                 ; konfiguracja do wypisania tekstu na ekran
        lea dx, GRACZ1_PUNKTY_TEKST ; dajemy do dx wskaznik do stringu z .data
        int 21h

        mov ah, 02h                 ; konfiguracja do ustawienia pozycji kursora
        mov bh, 00h                 ; konfiguracja do numeru strony
        mov dh, 2d                  ; wiersz
        mov dl, 70d                 ; kolumna
        int 10h                     ; wywolanie ustawien

        mov ah, 09h                 ; konfiguracja do wypisania tekstu na ekran
        lea dx, GRACZ2_PUNKTY_TEKST ; dajemy do dx wskaznik do stringu z .data
        int 21h

        ret
    RYSUJ_PUNKTY ENDP
    


    MAIN PROC
        ; przygotowanie segmentu danych
        push ds
        mov ax, @data
        mov ds, ax
        
        call CZYSC_EKRAN                ; tutaj ta procedura sluzy do pierwszego ustawienia trybu video


        CZAS:
            ; pozyskanie czasu systemowego
            mov ah, 2Ch
            int 21h

            cmp dl, RAMKA_CZASU         ; porownanie do sprawdzania czy czas uplynal
            je CZAS                     ; jesli czas nie uplynal sprawdz jeszcze raz
            
            mov RAMKA_CZASU, dl         ; po uplywie czasu jako ramke czasu dajemy aktualna wartosc czasu

            call CZYSC_EKRAN            ; wyczyszczenie ekranu po narysowaniu

            call PRZESUN_PILKE
            call RYSUJ_PILKE

            call PRZESUN_PALETKI
            call RYSUJ_PALETKI

            call RYSUJ_PUNKTY

            jmp CZAS

        mov AH, 4Ch   ; Funkcja INT 21h - zakończenie programu
        int 21h
    MAIN ENDP

END MAIN
