module uart_tx (
    input clk, 
    input rst,
    input load,
    input [7:0] data,
    output reg tx,
    output reg busy
);
reg [1:0] states;
reg [3:0] bit_count;
parameter clk_freq=10000000;
parameter baud_rate=1000000;
localparam baud=clk_freq/baud_rate;
reg [15:0] tick=0;
reg [9:0] shift_reg;

localparam idle=2'b00;
localparam start=2'b01;
localparam data_tx=2'b10;
localparam stop=2'b11;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        states<=idle;
        bit_count<=0;
        tick<=0;
        tx<=1'b1;
        busy<=1'b0;
    end
    else begin
        case(states)
            idle: begin
                bit_count<=0;
                tick<=0;
                tx<=1'b1;
                busy<=1'b0;
                if(load) begin
                    states<=start;
                    busy<=1'b1;
                    shift_reg<={1'b1,data,1'b0};
                end
            end
            start: begin
                busy<=1'b1;
                if(tick==baud-1) begin
                    tick<=0;
                    tx<=shift_reg[0];
                    states<=data_tx;
                    bit_count<=bit_count+1;
                    shift_reg<=shift_reg>>1;
                end
                else begin
                    tick<=tick+1;
                end
            end
            data_tx: begin
                if(tick==baud-1) begin
                    tick<=0;
                    tx<=shift_reg[0];
                    if(bit_count==8) begin
                        states<=stop;
                        busy<=1'b0;
                    end
                    else begin
                        states<=data_tx;
                        busy<=1'b1;
                    end
                    bit_count<=bit_count+1;
                    shift_reg<=shift_reg >> 1;
                end
                else begin
                    tick<=tick+1;
                end
            end
            stop: begin
                busy<=1'b0;
                if(tick==baud-1) begin
                    tick<=0;
                    tx<=shift_reg[0];
                    states<=idle;
                    bit_count<=1'b0;
                end
                else begin
                    tick<=tick+1;
                end
            end
        endcase
    end
end
endmodule