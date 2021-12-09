program schro
    !! all the comment starting by !! are added
    implicit none
    INTEGER (KIND=4), PARAMETER :: N=50
    INTEGER (KIND=4):: NCMAX, IFLAG, M, JLEV, NCOUNT, NODE,I 
    REAL (KIND=8), DIMENSION(0:N):: V,F,RR !! potential ; wave function ; abscissae
    REAL (KIND=8), DIMENSION(0:N):: RV, VRV
    REAL (KIND=8):: R0,RN,A,B,EPS,TOL,FINIT,ENERG,H,HC,E,DE,step
    REAL :: plot = 1
    
    ! initialize the data
    DATA R0/0.1D0/, RN/2.6D0/, a/1.3924/, b/1.484D-03/, EPS/1.0D-10/, TOL/1.0D-04/,& 
            FINIT/0.D0/, ENERG/-0.96D0/, NCMAX/30/, IFLAG/1/, M/11/, JLEV/0/ 

    H=(RN-R0)/DFLOAT(N)  ! calculation of the step:
    HC=H*H/B ! expression h2/b !!just a constant to compute the wave function

    ! calculation of the vector V(0:N) containing the potential 
    CALL POT(N,R0,H,A,RR,V)
    
    ! putting the trial energy value: 
    E=ENERG
    NCOUNT=0 

    WRITE(*,*) "No ITER  ENERG           M         DE        NODES" 



    !! loop : shoot again as long as ABS(DE/E).GT.TOL (see the last IF)
    3 CONTINUE

    ! propagation; NCOUNT giving the number of iterations:
    


    ! ### QUESTION 4 ###
    !
    !OPEN(UNIT=98,FILE="results/de_variation.dat")
    !ENERG = -0.98D0
    !do i=0,580
    !    step = 1.0 / 1000.0
    !    E = ENERG + step * i
    !    print *, E
    !    CALL SHOOT(N,HC,FINIT,EPS,E,V,F,NODE,DE,M,IFLAG) 
    !    WRITE(98,99) E, DE
    !    99 FORMAT(2E15.7) 
    !enddo
    !stop


    

    CALL SHOOT(N,HC,FINIT,EPS,E,V,F,NODE,DE,M,IFLAG) 
    NCOUNT=NCOUNT+1 

    WRITE(*,200) NCOUNT, E, M, DE, NODE 
    200 FORMAT(I4,5X, E15.7,I4,E15.7,I4)

    

    !! if we did the max nb of iteration, go the 999 (line 45) :
    IF(NCOUNT.GT.NCMAX) GOTO 999
    
    E=E+DE !! correct the value of E
    IF(ABS(DE/E).GT.TOL) GOTO 3 !! if ... then go the 3 (line 24)
    !! line above : equivalent of a while, recompute a shoot and display a new line



    ! writing the wave function: 
    OPEN(UNIT=1,FILE="results/Wavefunction.txt")
    DO I=0,N 
        WRITE(1,100) RR(I),F(I) 
        100 FORMAT(2E15.7) 
    ENDDO 
    CLOSE(1) 

    


    print *, "RR -----------------"
    print *, F
    
    print *, "F -----------------"
    print *, RR

    print *, "RV -----------------"
    RV = dot_product(1/(RR*RR), F)
    print *, RV

    print *, "VRV -----------------"
    VRV = dot_product(F, RV)
    print *, VRV

    print *, "BVRV -----------------"
    !BVRV = B * VRV
    print *, B * VRV

    print *, "Voila -------------------"






    IF(plot == 1) THEN
        call execute_command_line('python3 plot.py')
    ENDIF

    STOP
    999 WRITE(*,*) "No convergence reached with",NCMAX," iterations" 

    contains
    SUBROUTINE POT(N,R0,H,A,RR,V)
        ! fill the array V for the potential and RR for the abscissae
        IMPLICIT NONE
        INTEGER (KIND=4):: N,I 
        REAL (KIND=8), DIMENSION(0:N):: V,RR !! the output
        REAL (KIND=8):: R0,H,A
        DO I=0,N 
            RR(I)=R0+I*H !! abscissae of each point of the potential
            V(I)=DEXP(-2.D0*A*(RR(I)-1.D0))-2.D0*DEXP(-A*(RR(I)-1.D0))  !! the potential
        ENDDO 
        RETURN 
    END SUBROUTINE

    SUBROUTINE SHOOT(N,HC,FINIT,EPS,E,V,F,NODE,DE,M,IFLAG) 
        IMPLICIT NONE 
        INTEGER (KIND=4):: N,NODE,M,IFLAG,ISTEP,IINIT,IFIN,I 
        REAL (KIND=8), DIMENSION(0:N):: V,F 
        REAL (KIND=8):: HC,FINIT,EPS,E,DE,F0,F1,COEFF,AN,FSM,FM 

        ISTEP=1   ! propagation do the right 
        IINIT=1 
        IFIN=N-1 
        IF(IFLAG.EQ.0) IFIN=M 
        F0=FINIT !! first value of wavefunction =0
        F1=EPS !! second value  of wavefunction =eps
        CALL PROPAG(N,HC,ISTEP,IINIT,IFIN,IFLAG,F0,F1,E,V,F,M) 
        FM=F(M) !! value of the wavefunction at value M (~ middle of RR (abscissae))

        ISTEP=-1 ! propagation to the left 
        IINIT=N-1 
        IFIN=M+1 
        F0=FINIT 
        F1=EPS 
        CALL PROPAG(N,HC,ISTEP,IINIT,IFIN,IFLAG,F0,F1,E,V,F,M) 
        COEFF=F(M)/FM 
        DO I=0,M-1 
            F(I)=F(I)*COEFF 
        ENDDO 

        NODE=0 ! calculation of nodes: 
        AN=0.D0 ! calculation of the norm for the wavefunction 

        DO I=1,N ! F0=0 
            AN=AN+F(I)*F(I) 
            IF(F(I)*F(I-1).LT.0.D0) NODE=NODE+1
        ENDDO 

        FSM=F(M+1)+F(M-1)-2.D0*F(M)  ! correction of the energy: 
        DE=F(M)*((V(M)-E)*F(M)-FSM/HC)/AN 
        RETURN 
    END SUBROUTINE

    SUBROUTINE PROPAG(N,HC,ISTEP,IINIT,IFIN,IFLAG,F0,F1,E,V,F,M) 
        IMPLICIT NONE 
        INTEGER (KIND=4):: N,ISTEP,IINIT,IFIN,IFLAG,M,I,I1 
        REAL (KIND=8), DIMENSION(0:N):: V,F 
        REAL (KIND=8):: HC,F0,F1,E 
        F(IINIT-ISTEP)=F0 
        F(IINIT)=F1 
        DO I=IINIT,IFIN,ISTEP 
            I1=I+ISTEP 
            F(I1)=(2.0D0+HC*(V(I)-E))*F(I)-F(I-ISTEP) 
            IF(IFLAG.EQ.ISTEP) THEN 
                IF(F(I1).LT.F(I)) THEN 
                    M=I1 !! consider it is the maximum abscissa if F starts to decrease again
                    RETURN 
                ENDIF 
            ENDIF 
        ENDDO 
        RETURN
    END SUBROUTINE

END program schro