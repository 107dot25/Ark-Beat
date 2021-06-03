#include<stdio.h>
int main()
{
    int i,j,k,m,n,sum=0;
    for(i = 0; i < 10; i++)
        for(j = 0; j < 10; j++)
            for(k = 0; k < 10; k++)
                for(m = 0; m < 10; m++)
                    for(n = 0; n < 10; n++)
    {
        sum += 1;
    }
    printf("%d",sum);

}
