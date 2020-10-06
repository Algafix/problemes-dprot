#include <openssl/md5.h>
#include <iostream>

using namespace std;

int main()
{
    int a = 2;
    int *b = &a;

    cout << "int size: " << sizeof(a) << endl;
    cout << "a addr: "<< &a << endl;
    cout << "b addr: "<< &b << endl;
    cout << "b addr - 1: "<< &b - 1 << endl;
    cout << "(int*)(b addr) - 1: " << (int*)&b - 1 << endl;
    cout << *((int*)&b - 1) << endl;


}