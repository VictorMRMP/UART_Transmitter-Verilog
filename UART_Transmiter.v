`timescale 1ns / 1ps // Define a unidade de tempo e a precisão do simulador

module UART_Transmiter #(  
    parameter DELAY_FRAMES = 234,         // Parâmetro que define o número de ciclos de clock para atingir o baud rate desejado (115200 bps)
    parameter MEMORY_LENGTH = 14          // Número total de caracteres a serem transmitidos
)(
    input clk,                            // Sinal de clock principal
    input rst,                            // Sinal de reset
    output uart_tx                        // Saída UART para transmissão de dados
);

    // Definição dos estados da máquina de estados finita (FSM)
    localparam TX_STATE_IDLE = 0;         // Estado de repouso
    localparam TX_STATE_START_BIT = 1;    // Estado de envio do bit de início
    localparam TX_STATE_WRITE = 2;        // Estado de envio dos bits de dados
    localparam TX_STATE_STOP_BIT = 3;     // Estado de envio do bit de parada

    // Definição de registradores para controle da FSM e transmissão
    reg [1:0] txState = 0;                // Armazena o estado atual da FSM
    reg [24:0] txCounter = 0;             // Contador para controlar os ciclos de clock entre os bits
    reg [7:0] dataOut = 0;                // Byte atual a ser transmitido
    reg [2:0] txBitNumber = 0;            // Número do bit sendo transmitido (0 a 7)
    reg [3:0] txByteCounter = 0;          // Contador do número de bytes transmitidos
    reg txPinRegister = 1;                // Registrador que controla o nível lógico da saída UART
    reg [7:0] name [MEMORY_LENGTH-1:0];   // Memória para armazenar os caracteres a serem transmitidos

    assign uart_tx = txPinRegister;       // Atribui o valor do registrador ao pino de saída UART

    // Inicialização dos caracteres a serem transmitidos
    initial begin
        name[0] = "V"; name[1] = "i"; name[2] = "c"; name[3] = "t";
        name[4] = "o"; name[5] = "r"; name[6] = " ";
        name[7] = "P"; name[8] = "a"; name[9] = "d"; name[10] = "i";
        name[11] = "a"; name[12] = "l"; name[13] = " ";
    end

    // Lógica da máquina de estados finita (FSM) acionada pelo clock ou reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin // Se o reset for acionado
            txState <= TX_STATE_IDLE;     // Retorna ao estado de repouso
            txCounter <= 0;               // Zera o contador de ciclos
            txByteCounter <= 0;           // Zera o contador de bytes
            txBitNumber <= 0;             // Zera o contador de bits
            txPinRegister <= 1;           // Define o pino de saída UART como inativo
        end else begin
            case (txState)
                TX_STATE_IDLE: begin
                    if (txByteCounter < MEMORY_LENGTH) begin // Verifica se ainda há bytes para transmitir
                        txState <= TX_STATE_START_BIT; // Transição para o estado de envio do bit de início
                        txCounter <= 0;              // Reinicia o contador
                    end
                end

                TX_STATE_START_BIT: begin
                    if (txCounter == DELAY_FRAMES) begin // Espera o tempo necessário para enviar o bit de início
                        txPinRegister <= 0;          // Define o pino UART como ativo (nível baixo)
                        txState <= TX_STATE_WRITE;   // Transição para o estado de envio dos bits de dados
                        dataOut <= name[txByteCounter]; // Carrega o próximo byte a ser transmitido
                        txBitNumber <= 0;           // Reinicia o contador de bits
                        txCounter <= 0;             // Reinicia o contador de ciclos
                    end else begin
                        txCounter <= txCounter + 1; // Incrementa o contador de ciclos
                    end
                end

                TX_STATE_WRITE: begin
                    if (txCounter == DELAY_FRAMES) begin // Espera o tempo necessário para enviar o próximo bit
                        txPinRegister <= dataOut[txBitNumber]; // Define o pino UART com base no bit atual
                        txCounter <= 0;             // Reinicia o contador de ciclos
                        if (txBitNumber == 7) begin // Verifica se todos os bits foram enviados
                            txState <= TX_STATE_STOP_BIT; // Transição para o estado de envio do bit de parada
                        end else begin
                            txBitNumber <= txBitNumber + 1; // Incrementa o contador de bits
                        end
                    end else begin
                        txCounter <= txCounter + 1; // Incrementa o contador de ciclos
                    end
                end

                TX_STATE_STOP_BIT: begin
                    if (txCounter == DELAY_FRAMES) begin // Espera o tempo necessário para enviar o bit de parada
                        txPinRegister <= 1;          // Define o pino UART como inativo (nível alto)
                        txCounter <= 0;             // Reinicia o contador de ciclos
                        if (txByteCounter == MEMORY_LENGTH - 1) begin // Verifica se todos os bytes foram enviados
                            txState <= TX_STATE_IDLE; // Retorna ao estado de repouso
                            txByteCounter <= 0;     // Reinicia o contador de bytes
                        end else begin
                            txByteCounter <= txByteCounter + 1; // Incrementa o contador de bytes
                            txState <= TX_STATE_START_BIT; // Transição para o estado de envio do bit de início do próximo byte
                        end
                    end else begin
                        txCounter <= txCounter + 1; // Incrementa o contador de ciclos
                    end
                end
            endcase
        end
    end
endmodule

