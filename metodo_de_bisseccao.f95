program metodo_de_bisseccao
    implicit none

    real(8), parameter :: L = 5.0D0
    real(8), parameter :: C = 0.0001D0
    real(8), parameter :: T = 0.05D0
    real(8), parameter :: TARGET = 0.01D0
    real(8), parameter :: EPSILON = 1.0D-6

    real(8) :: a
    real(8) :: b
    real(8) :: R
    real(8) :: fa
    real(8) :: fb
    integer :: unit_file = 10
    integer :: iteracao = 0
    integer :: escolha, tentativas
    logical :: continuar
    character(len=1) :: resposta
    character(len=1) :: resposta_manual

    open(unit=unit_file, file="resultado_bisseccao.csv", status="unknown", action="write") 
    write(unit_file, '(A)') "Iteracao,Intervalo_A,Intervalo_B,Ponto_Medio,Valor_F(PMI)"

    do
        print *, "Escolha a opção para encontrar a raiz:"
        print *, "1 - Procurar a raiz antes do zero (números negativos)"        
        print *, "2 - Procurar a raiz depois do zero (números positivos)"       
        print *, "3 - Definir o intervalo manualmente"                          
        read *, escolha

        if (escolha .ge. 1 .and. escolha .le. 3) then
            exit
        else
            print *, new_line('a'), " *****************************************************************************"
            print *, " Opção inválida! Tente novamente."
            print *, "*****************************************************************************", new_line('a')
        end if
    end do

    select case (escolha)
    case (1)  
        a = -0.1D0
        b = -100.0D0
        tentativas = 0
        continuar = .true.

        print *, new_line('a'), "Fase 1: achar a raiz", new_line('a')
        do while (fa * fb >= 0.0D0 .and. tentativas < 100)
            a = a * 2.0D0
            b = b / 2.0D0
            fa = equacao(a)
            fb = equacao(b)
            tentativas = tentativas + 1
            print *, "Novo intervalo negativo: [", a, ", ", b, "]"
        end do

        if (fa * fb >= 0.0D0 .and. tentativas >= 100) then
            print *, "Não foi possível encontrar uma raiz no intervalo negativo após 100 iterações."
            print *, "Deseja continuar procurando? (S/N)"
            read *, resposta
            if (resposta == 'S' .or. resposta == 's') then
                continuar = .true.
            else
                continuar = .false.
            end if
            if (.not. continuar) then
                stop "Execução interrompida pelo usuário."
            end if
        end if

        R = bisseccao(a, b, unit_file, iteracao)

    case (2)
        a = 0.1D0
        b = 100.0D0
        fa = equacao(a)
        fb = equacao(b)

        print *, new_line('a'), "Fase 1: achar a raiz", new_line('a')
        do while (fa * fb >= 0.0D0)
            a = a / 2.0D0
            b = b * 2.0D0
            fa = equacao(a)
            fb = equacao(b)
            print *, "Novo intervalo positivo: [", a, ", ", b, "]"
        end do

        R = bisseccao(a, b, unit_file, iteracao)

    case (3)
        print *, "Deseja inserir manualmente o intervalo? (S/N)"
        read *, resposta_manual
        
        if (resposta_manual == 'S' .or. resposta_manual == 's') then
            print *, "Digite o valor do limite inferior do intervalo (a):"
            read *, a
            print *, "Digite o valor do limite superior do intervalo (b):"
            read *, b
            
            fa = equacao(a)
            fb = equacao(b)
            
            if (fa * fb >= 0.0D0) then
                print *, "Erro: O intervalo fornecido não possui sinais opostos."
                print *, "Tente outro intervalo onde a função mude de sinal."
                stop "Intervalo inválido fornecido."
            end if
        else
            a = -0.1D0
            b = 0.1D0
            fa = equacao(a)
            fb = equacao(b)
            if (fa * fb >= 0.0D0) then
                print *, "Erro: O intervalo padrão não possui sinais opostos. Tente outro intervalo."
                stop "Intervalo inválido fornecido."
            end if
        end if
        
        R = bisseccao(a, b, unit_file, iteracao)

    end select

    close(unit_file)
    
    print *, "O valor de R que atende é aproximadamente:", R

contains

    function equacao(R) result(f)
        real(8), intent(in) :: R
        real(8) :: alpha
        real(8) :: frequencia_quadrado
        real(8) :: frequencia_angular
        real(8) :: termo_exp, termo_cos
        real(8) :: f
        
        alpha = R / (2.0D0 * L)
        frequencia_quadrado = (1.0D0 / (L * C)) - (R**2 / (4.0D0 * L**2)) 
        
        if (frequencia_quadrado < 0.0D0) then
            f = TARGET
            return
        endif
        
        frequencia_angular = sqrt(frequencia_quadrado)
        termo_exp = exp(-alpha * T)
        termo_cos = cos(frequencia_angular * T)
        f = TARGET - (termo_exp * termo_cos)
    end function equacao

    function bisseccao(a, b, unit_file, iteracao) result(raiz)
        real(8), intent(inout) :: a, b
        integer, intent(in) :: unit_file
        integer, intent(inout) :: iteracao
        real(8) :: raiz
        real(8) :: pmi, fpa, fpb, fpmi
        
        fpa = equacao(a)
        fpb = equacao(b)
            
        print *, new_line('a'), new_line('a'), "Fase 2: Refinar a raiz", new_line('a')
        print *, "*****************************************************************************"
        print *, "*                 Detalhes do refinamento em arquivo CSV                    *"
        print *, "*****************************************************************************", new_line('a')
        
        do while ((b - a) / 2.0D0 > EPSILON .and. iteracao < 100)
            pmi = (a + b) / 2.0D0
            fpmi = equacao(pmi)
            
            iteracao = iteracao + 1
            write(unit_file, '(I4,1X,F12.6,1X,F12.6,1X,F12.6,1X,F12.6)') iteracao, a, b, pmi, fpmi
            
            if (abs(fpmi) < EPSILON) then
                raiz = pmi
                return
            else if (fpa * fpmi < 0.0D0) then
                b = pmi
                fpb = fpmi
            else
                a = pmi
                fpa = fpmi
            endif
        end do
        
        raiz = (a + b) / 2.0D0
    end function bisseccao

end program metodo_de_bisseccao

