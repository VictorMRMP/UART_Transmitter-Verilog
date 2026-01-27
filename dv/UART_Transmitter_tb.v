//`include "UART_Transmitter_Testbench.v" // Inclui o módulo Transmiter para teste
`timescale 1ns / 1ps    // Define a unidade de tempo e a precisão do simulador

module UART_Receiver;

    // Parâmetros de configuração
    parameter DELAY_FRAMES = 234; // Define o número de ciclos para atingir o baud rate de 115200
    parameter CLK_PERIOD = 37;    // Define o período do clock principal (frequência de 27 MHz)

    // Declaração das entradas e saídas
    reg clk;                      // Sinal de clock principal
    reg rst;                      // Sinal de reset
    wire uart_tx;                 // Linha de transmissão UART simulada

    // Variáveis utilizadas no teste
    reg [7:0] received_data;      // Armazena o dado recebido pela UART
    integer i, bit_count;         // Variáveis de controle para o loop de leitura
    reg start_detected;           // Flag para detectar o bit de início (start bit)

    // Instanciação do DUT (Device Under Test)
    UART_Transmiter #(.DELAY_FRAMES(DELAY_FRAMES)) dut (
        .clk(clk),
        .rst(rst),
        .uart_tx(uart_tx)
    );

    // Geração do clock (sinal alternado)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Inverte o valor do clock a cada metade do período
    end

    // Processo principal do teste
    initial begin
        // Inicialização das variáveis
        rst = 1;                  // Ativa o reset inicialmente
        received_data = 8'b0;     // Limpa o registrador de dados recebidos
        start_detected = 0;       // Inicializa o flag de detecção do start bit

        // Aplica o reset no DUT
        #100;                     // Aguarda 100 ns
        rst = 0;                  // Desativa o reset

        // Monitoramento da transmissão UART
        bit_count = 0;            // Inicializa o contador de bits
        while ($time < 10000000) begin // Define um limite de tempo para a simulação (1 segundo)
            // Aguarda o start bit (nível baixo na linha UART)
            wait (uart_tx == 0);
            start_detected = 1;   // Sinaliza que o start bit foi detectado
            received_data = 8'b0; // Limpa os dados recebidos
            bit_count = 0;        // Reinicia o contador de bits

            // Espera o meio do período do start bit
            #(DELAY_FRAMES * CLK_PERIOD / 2);

            // Lê os 8 bits de dados no meio do período de cada bit
            for (i = 0; i < 8; i = i + 1) begin
                #(DELAY_FRAMES * CLK_PERIOD); // Aguarda o próximo bit
                received_data[i] = uart_tx;  // Armazena o bit atual no registrador
            end

            // Verifica o bit de parada (stop bit)
            #(DELAY_FRAMES * CLK_PERIOD);
            if (uart_tx != 1) begin // Se o stop bit não for nível alto, há um erro
                $display("Erro: Stop bit inválido em %0dns", $time);
            end

            // Exibe o caractere recebido no terminal
            $display("Time %0dns: Character received: %c", $time, received_data);
        end

        // Finaliza a simulação após 1 segundo
        $display("Simulação finalizada em %0dns", $time);
        $finish; // Encerra a simulação
    end
endmodule

