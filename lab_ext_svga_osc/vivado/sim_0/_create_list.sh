sed -e '/^;\|^$/! s/src/..\/..\/src/' ../../src/systemverilog.f > systemverilog.f
sed -e '/^;\|^$/! s/src/..\/..\/src/' ../../src/verilog.f > verilog.f

sed -e '/^;\|^$/! s/tb/..\/..\/tb/' ../../tb/systemverilog.f >> systemverilog.f

# Замена команды -i на incdir для поиска включаемых файлов по команде `include
sed -i 's/-i /--include/g' verilog.f
sed -i 's/-i/--include/g' systemverilog.f