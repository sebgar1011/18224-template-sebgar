    `default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);

    // input mapping
    logic [9:0] data_in;
    assign data_in = io_in[9:0];
    
    logic go, finish;
    assign go = io_in[10];
    assign finish = io_in[11];

    // output mapping
    logic [9:0] range;
    assign io_out[9:0] = range;
    logic debug_error;
    assign io_out[10] = debug_error;
    
    enum logic [1:0] {IDLE, READING, FINISH, ERROR} state, next_state;

    // control pts
    logic clear, en_min, en_max;

    // dp outputs
    logic [WIDTH-1:0] low_q, high_q;

    // next state logic
    always_comb begin
        case(state)
        IDLE: begin
            if (go && !finish) next_state = READING;
            else if (finish) next_state = ERROR;
            else if (go && finish) next_state = ERROR;
            else next_state = state;
        end
        READING: begin
            if (!finish) next_state = state;
            else next_state = FINISH;
        end
        FINISH: begin
            if (!finish && !go) next_state = IDLE;
            else if (!finish && go) next_state = READING;
            else next_state = state;
        end
        ERROR: begin
            if (go && !finish) next_state = READING;
            else next_state = state;
        end
        endcase
    end

    // output logic
    always_comb begin

        case(state)
        IDLE: begin
            if (go && !finish) begin
                clear = 0;
                en_min = 1;
                en_max = 1;
                debug_error = 0;
            end
            else if ((go && finish) || finish) begin
                debug_error = 1;
                clear = 1;
                en_min = 0;
                en_max = 0;
            end
            else begin
                debug_error = 0;
                clear = 1;
                en_min = 0;
                en_max = 0;
            end
        end
        READING: begin
            debug_error = 0;
            if (!finish) begin
                clear = 0;
                if (data_in < low_q) en_min = 1;
                else en_min = 0;
                if (data_in > high_q) en_max = 1;
                else en_max = 0;
            end
            else begin
                en_min = 0;
                en_max = 0;
                clear = 0;
            end
        end
        FINISH: begin
            debug_error = 0;
            clear = 0;
            en_min = 0;
            en_max = 0;
        end
        ERROR: begin
            clear = 1;
            en_min = 0;
            en_max = 0;
            debug_error = 1;
        end
        endcase
    end 

    // next state transition
    always_ff @(posedge clock, posedge reset) begin
        if (reset) state <= IDLE;
        else if (clock) state <= next_state;
    end

    // datapath
    Register #(WIDTH) Register_min_inst(.D(data_in), .en(en_min), .clear, .clock, .Q(low_q));
    
    Register #(WIDTH) Register_max_inst(.D(data_in), .en(en_max), .clear, .clock, .Q(high_q));
    assign range = high_q - low_q;

endmodule: my_chip

