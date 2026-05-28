module uart_rx (
    input clk,
    input rst,
    input rx,    //incoming data
    output reg [7:0] data
);
reg [1:0]states;
reg [3:0] bit_count;
reg [15:0] ticks;
reg [9:0] shift_reg;
reg flag;

parameter clk_freq=10000000;
parameter baud_rate=1000000;
localparam baud=clk_freq/baud_rate;

localparam idle=2'b00;
localparam start=2'b01;
localparam data_rx=2'b10;
localparam stop=2'b11;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        states<=idle;
        bit_count<=0;
        ticks<=0;
        shift_reg<=10'b0000000000;
        data<=8'b00000000;
    end
    else begin
        case(states)
            idle: begin
                bit_count<=0;
                ticks<=0;
                shift_reg<=10'b0000000000;
                if(rx==0) begin
                    states<=start;
                end   
            end
            start:begin
                if(ticks==baud/2 -1) begin
                    ticks<=0;
                    if(rx==0) begin
                        states<=data_rx;
                        shift_reg[bit_count]<=rx;
                        bit_count<=bit_count+1;
                    end
                    else begin
                        states<=idle;
                    end
                end
                else begin
                    ticks<=ticks+1;
                end
            end
            data_rx: begin
                if(ticks==baud-1) begin
                    ticks<=0;
                    if(bit_count==8) begin
                        states<=stop;
                    end
                    else begin
                        states<=data_rx;
                    end
                    shift_reg[bit_count]<=rx;
                    bit_count<=bit_count+1;
                end
                else begin
                    ticks<=ticks+1;
                end
            end
            stop:begin
                if(ticks==baud-1) begin
                    if(rx==1) begin
                        ticks<=0;
                        shift_reg[bit_count]<=rx;
                        states<=idle;
                        bit_count<=1'b0;
                        data<=shift_reg[8:1];
                    end
                    else begin
                        states <= idle;
                    end
                end
                else begin
                    ticks<=ticks+1;
                end
            end
        endcase
    end
end
endmodule