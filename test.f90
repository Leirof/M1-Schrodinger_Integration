PROGRAM SCHROD 
    IMPLICIT NONE 
    INTEGER (KIND=4), PARAMETER :: N=700 
    INTEGER (KIND=4):: NCMAX, IFLAG, M, JLEV, NCOUNT, NODE,I 
    REAL (KIND=8), DIMENSION(0:N):: V,F,RR 
    REAL (KIND=8):: R0,RN,A,B,EPS,TOL,FINIT,ENERG,H,HC,E,DE, LOOP_ENERGY
    character(len=2) :: str_node
    integer :: bulk = 0
    REAL (KIND=8):: cpt = 0.0

    ENERG=-0.96D0

    ENERG = ENERG - 0.005

    97 CONTINUE
    DATA R0/0.01D0/,     &! r_0
        RN/4.0D0/,      &! r_N
        A/1.3924/,      &! a
        B/1.484D-03/,   &! b
        EPS/1.0D-04/,   &! \epsilon
        TOL/1.0D-04/,   &! \tau
        FINIT/0.D0/,    &!
        !ENERG/-0.96D0/, &!
        NCMAX/30/,      &!
        IFLAG/1/,       &!
        M/11/,          &!
        JLEV/0/ 

    ENERG = ENERG + 0.005
    !RN = 2.6D0 + cpt * 0.3
    !cpt = cpt + 1
    
    H=(RN-R0)/DFLOAT(N)  ! calculation of the step: 
    HC=H*H/B ! expression h2/b 
    ! calculation of the vector V(0:N) containing the potential 
    CALL POT(N,R0,H,A,B,JLEV,RR,V) 
    ! putting the trial energy value: 
    E=ENERG 
    NCOUNT=0 
    WRITE(*,*) "No ITER  ENERG           M         DE        NODES" 
    3 CONTINUE  
    ! propagation; NCOUNT giving the number of iterations: 
    CALL SHOOT(N,A,H,HC,FINIT,EPS,E,V,F,NODE,DE,M,IFLAG) 
    NCOUNT=NCOUNT+1 
    WRITE(*,200) NCOUNT, E, M, DE, NODE 
    200 FORMAT(I4,5X, E15.7,I4,E15.7,I4) 
    IF(NCOUNT.GT.NCMAX) GOTO 999 
    E=E+DE 
    IF(ABS(DE/E).GT.TOL) GOTO 3 

    ! writing the wave function: 
    write (str_node, "(I2)") NODE
    !write(str_node,'(I5)') NODE
    print *, trim(str_node)
    IF(bulk == 1) THEN
        OPEN(UNIT=1,FILE="results/Wavefunction_" // str_node // ".txt") 
    ELSE
        OPEN(UNIT=1,FILE="results/Wavefunction.txt") 
    ENDIF
    
    DO I=0,N
        WRITE(1,100) RR(I),F(I) 
        100 FORMAT(2E15.7) 
    ENDDO 
    CLOSE(1)
    
    IF(bulk == 1) THEN
        IF(ENERG <= 0.01) THEN
            GOTO 97
        ELSE
            call execute_command_line('python3 plot_psy.py bulk')
        ENDIF
    ELSE 
        call execute_command_line('python3 plot_psy.py')
    ENDIF


    STOP 
    999 WRITE(*,*) "No convergence reached with",NCMAX," iterations" 
END 
     
SUBROUTINE POT(N,R0,H,A,B,JLEV,RR,V) 
    IMPLICIT NONE 
    INTEGER (KIND=4):: N,JLEV,I 
    REAL (KIND=8), DIMENSION(0:N):: V,RR 
    REAL (KIND=8):: R0,H,A,B 

    DO I=0,N 
        RR(I)=R0+I*H 
        V(I)=DEXP(-2.D0*A*(RR(I)-1.D0))-2.D0*DEXP(-A*(RR(I)-1.D0)) 
    ENDDO 
    RETURN 
 END 

SUBROUTINE SHOOT(N,A,H,HC,FINIT,EPS,E,V,F,NODE,DE,M,IFLAG) 
    IMPLICIT NONE 
    INTEGER (KIND=4):: N,NODE,M,IFLAG,ISTEP,IINIT,IFIN,I 
    REAL (KIND=8), DIMENSION(0:N):: V,F 
    REAL (KIND=8):: A,B,H,HC,FINIT,EPS,E,DE,F0,F1,COEFF,AN,FSM,FM

    ISTEP=1   ! propagation do the right 
    IINIT=1 
    IFIN=N-1 
    IF(IFLAG.EQ.0) IFIN=M 
    F0=FINIT 
    F1=EPS 
    CALL PROPAG(N,HC,ISTEP,IINIT,IFIN,IFLAG,F0,F1,E,V,F,M) 
    FM=F(M) 
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
END 
     
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
            M=I1 
            RETURN 
            ENDIF 
        ENDIF 
    ENDDO 
    RETURN 
END