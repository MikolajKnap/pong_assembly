.286
.model large
.stack 100h

.DATA
    ; -------------------------------- pilka -------------------------------
    PILKA_X_START DW 160
    PILKA_Y_START DW 110
    PILKA_X DW 30d
    PILKA_Y DW 90d
    PILKA_ROZMIAR DW 04h
    PILKA_SZYBKOSC_X DW 5
    PILKA_SZYBKOSC_Y DW 2

    ; ------------------------------ platformy -----------------------------
    PLATFORMA_LEWA_X DW 10d
    PLATFORMA_LEWA_Y DW 10d
    PLATFORMA_PRAWA_X DW 305d
    PLATFORMA_PRAWA_Y DW 10d
    PLATFORMA_SZEROKOSC DW 4d
    PLATFORMA_WYSOKOSC DW 33d
    PLATFORMA_SZYBKOSC DW 5d

    ; ----------------------------- czas i okno 320x200 ---------------------
    RAMKA_CZASU DB 0

    OKNO_SZEROKOSC DW 320d
    OKNO_WYSOKOSC DW 200d
    OKNO_OGRANICZENIE DW 4d

.CODE
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

    ; ----------------------------------------------- PRZESUN PILKE PROC ---------------------------------------------
    PRZESUN_PILKE PROC
        
        ; przesuwanie pilki po X
        mov ax, PILKA_SZYBKOSC_X                ; zapisanie do ax predkosci pilki po osi X
        add PILKA_X, ax                         ; zwiekszenie pozycji pilki o predkosc osi X

        ; kolizja lewa scianka
        mov ax, OKNO_OGRANICZENIE
        cmp PILKA_X, ax                         ; porownujemy pozycje X pilki do lewej krawedzi
        JL ZAMIEN_PREDKOSC_X                        ; jesli mniejsza niz lewa krawedz to skaczemy

        ; kolizja prawa scianka
        mov ax, OKNO_SZEROKOSC                  ; zapis szerokosci okna do ax
        sub ax, PILKA_ROZMIAR
        sub ax, OKNO_OGRANICZENIE               ; zmniejszamy wartosc rozmiaru okna o wartosc rozmiaru pilki, w celu lepszej kolizji
        cmp PILKA_X, ax                         ; porownanie pozycji X pilki do prawej krawedzi
        jg ZAMIEN_PREDKOSC_X                        ; jesli wieksza niz prawa krawedz to skaczemy

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

        ret

        ZAMIEN_PREDKOSC_X:
            NEG PILKA_SZYBKOSC_X                ; zanegowanie predkosci pilki po x
            ret

        ZAMIEN_PREDKOSC_Y:
            NEG PILKA_SZYBKOSC_Y                ; zanegowanie predkosci pilki po y
            ret
        
        RESETUJ_PILKE:
            call RESET_PILKA
            ret

    PRZESUN_PILKE ENDP

    ; ----------------------------------------------- RYSUJ PLATFORMY PROC ---------------------------------------------
    RYSUJ_PLATFORMY PROC

        ; --- rysowanie lewej platformy ---
        mov cx, PLATFORMA_LEWA_X                    ; pozycja poczatkowa X platformy
        mov dx, PLATFORMA_LEWA_Y                    ; pozycja poczatkowa Y platformy

        RYSUJ_PLATFORME_LEWA_HORYZONTALNIE:
            mov ah, 0Ch                             ; ustawienie konfiguracji int 10h na rysowanie pikseli
            mov al, 0Fh                             ; wybranie bialego koloru
            mov bh, 00h                             ; wybranie strony 0
            int 10h                                 ; rysowanie piksela

            inc cx                                  ; zwiekszamy pozycje X o 1
            mov ax, cx                              ; przenosimy rejestr cx do ax - w celu obliczen
            sub ax, PLATFORMA_LEWA_X                ; odejmujemy od aktualnej pozycji X poczatkowa pozycje X
            cmp ax, PLATFORMA_SZEROKOSC             ; sprawdzamy czy nowa pozycja X jest wieksza niz wielkosc platformy
            jng  RYSUJ_PLATFORME_LEWA_HORYZONTALNIE ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; przejscie do nastepnej lini
        mov cx, PLATFORMA_LEWA_X                    ; wracamy z poczatkowa pozycja X pilki
        inc dx                                      ; zwiekszamy wiersz o 1, czyli nastepna linia

        ; rysowanie platformy lewej wertykalnie
        mov ax, dx                                  ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PLATFORMA_LEWA_Y                    ; odejmujemy od aktualnej pozycji Y poczatkowa pozycje Y
        cmp ax, PLATFORMA_WYSOKOSC                  ; sprawdzamy czy nowa pozycja Y jest wieksza niz wysokosc platformy
        jng RYSUJ_PLATFORME_LEWA_HORYZONTALNIE      ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; --- rysowanie prawej platformy ---
        mov cx, PLATFORMA_PRAWA_X                    ; pozycja poczatkowa X platformy
        mov dx, PLATFORMA_PRAWA_Y                    ; pozycja poczatkowa Y platformy

        RYSUJ_PLATFORME_PRAWA_HORYZONTALNIE:
            mov ah, 0Ch                             ; ustawienie konfiguracji int 10h na rysowanie pikseli
            mov al, 0Fh                             ; wybranie bialego koloru
            mov bh, 00h                             ; wybranie strony 0
            int 10h                                 ; rysowanie piksela

            inc cx                                  ; zwiekszamy pozycje X o 1
            mov ax, cx                              ; przenosimy rejestr cx do ax - w celu obliczen
            sub ax, PLATFORMA_PRAWA_X                ; odejmujemy od aktualnej pozycji X poczatkowa pozycje X
            cmp ax, PLATFORMA_SZEROKOSC             ; sprawdzamy czy nowa pozycja X jest wieksza niz wielkosc platformy
            jng  RYSUJ_PLATFORME_PRAWA_HORYZONTALNIE ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ; przejscie do nastepnej lini
        mov cx, PLATFORMA_PRAWA_X                    ; wracamy z poczatkowa pozycja X pilki
        inc dx                                      ; zwiekszamy wiersz o 1, czyli nastepna linia

        ; rysowanie platformy prawej wertykalnie
        mov ax, dx                                  ; przenosimy rejestr cx do ax - w celu obliczen
        sub ax, PLATFORMA_PRAWA_Y                    ; odejmujemy od aktualnej pozycji Y poczatkowa pozycje Y
        cmp ax, PLATFORMA_WYSOKOSC                  ; sprawdzamy czy nowa pozycja Y jest wieksza niz wysokosc platformy
        jng RYSUJ_PLATFORME_PRAWA_HORYZONTALNIE      ; jesli nie jest to loopujemy i rysujemy obok, a jesli jest to nastepnia linia

        ret

    RYSUJ_PLATFORMY ENDP
    
    ; ----------------------------------------------- PRZESUN PLATFORMY PROC ---------------------------------------------
    PRZESUN_PLATFORMY PROC
        ; sprawdzamy czy klawisz zostal wcisniety
        mov ah, 01h
        int 16h
        jz SPRAWDZ_PRAWA_PLATFORME

        ; sprawdzamy ktory klawisz zostal wcisniety q (w gore) = 71 ascii, a (w dol) = 61 ascii
        mov ah, 00h
        int 16h

        cmp al, 71h ; q
        je PRZESUN_LEWA_PLATFORME_W_GORE
        cmp al, 61h ; a
        je PRZESUN_LEWA_PLATFORME_W_DOL
        jmp SPRAWDZ_PRAWA_PLATFORME

        PRZESUN_LEWA_PLATFORME_W_GORE:
            mov ax, PLATFORMA_SZYBKOSC
            sub PLATFORMA_LEWA_Y, ax

            mov ax, OKNO_OGRANICZENIE
            cmp PLATFORMA_LEWA_Y, ax
            jl POPRAW_LEWA_PLATFORME_GORA
            jmp SPRAWDZ_PRAWA_PLATFORME

            POPRAW_LEWA_PLATFORME_GORA:
                mov ax, OKNO_OGRANICZENIE
                mov PLATFORMA_LEWA_Y, ax
                jmp SPRAWDZ_PRAWA_PLATFORME

        PRZESUN_LEWA_PLATFORME_W_DOL:
            mov ax, PLATFORMA_SZYBKOSC
            add PLATFORMA_LEWA_Y, ax
            mov ax, OKNO_WYSOKOSC
            sub ax, OKNO_OGRANICZENIE
            sub ax, PLATFORMA_WYSOKOSC
            cmp PLATFORMA_LEWA_Y, ax
            jg POPRAW_LEWA_PLATFORME_DOL
            jmp SPRAWDZ_PRAWA_PLATFORME

            POPRAW_LEWA_PLATFORME_DOL:
                mov PLATFORMA_LEWA_Y, ax
                JMP SPRAWDZ_PRAWA_PLATFORME
        
        SPRAWDZ_PRAWA_PLATFORME:

            cmp al, 70h ; p
            je PRZESUN_PRAWA_PLATFORME_W_GORE
            cmp al, 6Ch ; l
            je PRZESUN_PRAWA_PLATFORME_W_DOL
            jmp WYJSCIE
            PRZESUN_PRAWA_PLATFORME_W_GORE:
                mov ax, PLATFORMA_SZYBKOSC
                sub PLATFORMA_PRAWA_Y, ax

                mov ax, OKNO_OGRANICZENIE
                cmp PLATFORMA_PRAWA_Y, ax
                jl POPRAW_PRAWA_PLATFORME_GORA
                jmp WYJSCIE

                POPRAW_PRAWA_PLATFORME_GORA:
                    mov ax, OKNO_OGRANICZENIE
                    mov PLATFORMA_PRAWA_Y, ax
                    jmp WYJSCIE

            PRZESUN_PRAWA_PLATFORME_W_DOL:
                mov ax, PLATFORMA_SZYBKOSC
                add PLATFORMA_PRAWA_Y, ax
                mov ax, OKNO_WYSOKOSC
                sub ax, OKNO_OGRANICZENIE
                sub ax, PLATFORMA_WYSOKOSC
                cmp PLATFORMA_PRAWA_Y, ax
                jg POPRAW_PRAWA_PLATFORME_DOL
                jmp WYJSCIE

                POPRAW_PRAWA_PLATFORME_DOL:
                    mov PLATFORMA_PRAWA_Y, ax
                    JMP WYJSCIE
        
        WYJSCIE:
        ret



    PRZESUN_PLATFORMY ENDP


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

            call PRZESUN_PLATFORMY
            call RYSUJ_PLATFORMY

            jmp CZAS

        MOV AH, 4Ch   ; Funkcja INT 21h - zakończenie programu
        INT 21h
    MAIN ENDP

END MAIN
