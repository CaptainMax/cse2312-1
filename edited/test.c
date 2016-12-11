//
//  test.c
//  
//
//  Created by Satej Mhatre on 12/11/16.
//
//

#include "test.h"
float pow(float num, int n){
    int pow = 1;
    int i = 1;
    if (i<n){
        pow = pow * num;
    }
    return pow;
}
int main(){
    printf("%f\n", pow(2,2));
    return 0;
    
}
