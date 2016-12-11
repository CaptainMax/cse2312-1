//
//  main.c
//  test
//
//  Created by Satej Mhatre on 12/11/16.
//  Copyright © 2016 Satej Mhatre. All rights reserved.
//

#include <stdio.h>
float power(float num, int n){
    int pow = 1;
    int i = 1;
    while (i<=n){
        pow = pow * num;
        ++i;
    }
    return pow;
}
int main(){
    printf("%f\n", power(2,5));
    return 0;
    
}
