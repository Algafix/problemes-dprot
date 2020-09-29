import csv 

# Original values

o_m0 = 'a'
o_key = '000102030405060708090a0b0c'

print()
print('message is: ' + o_m0)
print('key is: ' + o_key)
print('\n=============================')

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
print('m[0]: ' + chr(m0) + '\t\t(with freq. ' + str(frequency) + 
        ')\t\t' + str(verification))
print('=============================')

############# Guessing key #############

recovered_key = []
iv_counter = 3
guess_counter = 6
k_byte = 0

with open('data_k.txt', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:

        if row['IV'] == '0'+format(iv_counter, 'x')+'ff00':
            # First value of this k
            # Set the frequence list to 0
            k_freq_list = []
            for k_value in range(0,255):
                k_freq_list.append(0)

        for k_value in range(0,255):
            # Computes the guessing for this IV value
            keystream_value = m0 ^ int('0x'+row['Ciphertext'],0)
            suposed_value = (int('0x'+row['IV'][-2:],0) + guess_counter + k_value) % 255
            if keystream_value == suposed_value:
                k_freq_list[k_value] += 1
        
        if row['IV'] == '0'+format(iv_counter, 'x')+'ffff':
            # Last value of this k
            # Saves and compares the guessed k
            frequency = max(k_freq_list)
            k = k_freq_list.index(frequency)
            recovered_key.append(k)
            verification = k == int('0x'+o_key[k_byte*2:k_byte*2+2],0)
            print('k['+str(k_byte)+']: ' + "{0:#0{1}x}".format(k,4) + 
                    '\t(with freq. ' + str(frequency) + ')\t\t' + str(verification))

            # Update the counters for next k guessing
            iv_counter += 1
            guess_counter += iv_counter + k
            k_byte += 1
            
# Console log of the key recovered

print('=============================\n')
recovered_key_string = ''.join(["{0:0{1}x}".format(x,2) for x in recovered_key])
if o_key == recovered_key_string:
    print('\033[32m Key recovered! \033[m\n\t' + o_key + ' == ' + recovered_key_string)
else:
    print('\033[31m Key not recovered \033[m\n\t' + o_key + ' != ' + recovered_key_string)

print()