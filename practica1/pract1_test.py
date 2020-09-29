import csv 

o_m0 = 'a'
o_key = '000102030405060708090a0b0c'

print('message is: ' + o_m0)
print('key is: ' + o_key)
print('=============================')

############# Guessing m0 #############

m0_freq_list = []

for m0_value in range(0,255):
    m0_freq_list.append(0)

with open('data_m0.txt', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        for m0_value in range(0,255):
            keystream_value = m0_value ^ int('0x'+row['Ciphertext'],0)
            suposed_value = (int('0x'+row['IV'][-2:],0) + 2) % 255
            if keystream_value == suposed_value:
                m0_freq_list[m0_value] += 1

frequency = max(m0_freq_list)
m0 = m0_freq_list.index(frequency)
verification = chr(m0) == o_m0
print('m[0]: ' + chr(m0) + '\t(with freq. ' + str(frequency) + ')\t\t' + str(verification))
print('=============================')

############# Guessing k0 #############

k0_freq_list = []

for k0_value in range(0,255):
    k0_freq_list.append(0)

with open('data_k0.txt', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        for k0_value in range(0,255):
            keystream_value = m0 ^ int('0x'+row['Ciphertext'],0)
            suposed_value = (int('0x'+row['IV'][-2:],0) + 6 + k0_value) % 255
            if keystream_value == suposed_value:
                k0_freq_list[k0_value] += 1

frequency = max(k0_freq_list)
k0 = k0_freq_list.index(frequency)
verification = k0 == int('0x'+o_key[:2],0)
print('k[0]: ' + "{0:#0{1}x}".format(k0,4) + '\t(with freq. ' + str(frequency) + ')\t\t' + str(verification))

############# Guessing k1 #############

k1_freq_list = []

for k1_value in range(0,255):
    k1_freq_list.append(0)

with open('data_k1.txt', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        for k1_value in range(0,255):
            keystream_value = m0 ^ int('0x'+row['Ciphertext'],0)
            suposed_value = (int('0x'+row['IV'][-2:],0) + 10 + k1_value) % 255
            if keystream_value == suposed_value:
                k1_freq_list[k1_value] += 1

frequency = max(k1_freq_list)
k1 = k1_freq_list.index(frequency)
verification = k1 == int('0x'+o_key[2:4],0)
print('k[1]: ' + "{0:#0{1}x}".format(k1,4) +  '\t(with freq. ' + str(frequency) + ')\t\t' + str(verification))

############ k1 determinado #############
