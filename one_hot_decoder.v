module one_hot_decoder(a,z);
    input [127:0] a;
    output reg [6:0] z;

    always @(a) begin
        case (a)
            128'd1: z <= 7'd0;
            128'd2: z <= 7'd1;
            128'd4: z <= 7'd2;
            128'd8: z <= 7'd3;
            128'd16: z <= 7'd4;
            128'd32: z <= 7'd5;
            128'd64: z <= 7'd6;
            128'd128: z <= 7'd7;
            128'd256: z <= 7'd8;
            128'd512: z <= 7'd9;
            128'd1024: z <= 7'd10;
            128'd2048: z <= 7'd11;
            128'd4096: z <= 7'd12;
            128'd8192: z <= 7'd13;
            128'd16384: z <= 7'd14;
            128'd32768: z <= 7'd15;
            128'd65536: z <= 7'd16;
            128'd131072: z <= 7'd17;
            128'd262144: z <= 7'd18;
            128'd524288: z <= 7'd19;
            128'd1048576: z <= 7'd20;
            128'd2097152: z <= 7'd21;
            128'd4194304: z <= 7'd22;
            128'd8388608: z <= 7'd23;
            128'd16777216: z <= 7'd24;
            128'd33554432: z <= 7'd25;
            128'd67108864: z <= 7'd26;
            128'd134217728: z <= 7'd27;
            128'd268435456: z <= 7'd28;
            128'd536870912: z <= 7'd29;
            128'd1073741824: z <= 7'd30;
            128'd2147483648: z <= 7'd31;
            128'd4294967296: z <= 7'd32;
            128'd8589934592: z <= 7'd33;
            128'd17179869184: z <= 7'd34;
            128'd34359738368: z <= 7'd35;
            128'd68719476736: z <= 7'd36;
            128'd137438953472: z <= 7'd37;
            128'd274877906944: z <= 7'd38;
            128'd549755813888: z <= 7'd39;
            128'd1099511627776: z <= 7'd40;
            128'd2199023255552: z <= 7'd41;
            128'd4398046511104: z <= 7'd42;
            128'd8796093022208: z <= 7'd43;
            128'd17592186044416: z <= 7'd44;
            128'd35184372088832: z <= 7'd45;
            128'd70368744177664: z <= 7'd46;
            128'd140737488355328: z <= 7'd47;
            128'd281474976710656: z <= 7'd48;
            128'd562949953421312: z <= 7'd49;
            128'd1125899906842624: z <= 7'd50;
            128'd2251799813685248: z <= 7'd51;
            128'd4503599627370496: z <= 7'd52;
            128'd9007199254740992: z <= 7'd53;
            128'd18014398509481984: z <= 7'd54;
            128'd36028797018963968: z <= 7'd55;
            128'd72057594037927936: z <= 7'd56;
            128'd144115188075855872: z <= 7'd57;
            128'd288230376151711744: z <= 7'd58;
            128'd576460752303423488: z <= 7'd59;
            128'd1152921504606846976: z <= 7'd60;
            128'd2305843009213693952: z <= 7'd61;
            128'd4611686018427387904: z <= 7'd62;
            128'd9223372036854775808: z <= 7'd63;
            128'd18446744073709551616: z <= 7'd64;
            128'd36893488147419103232: z <= 7'd65;
            128'd73786976294838206464: z <= 7'd66;
            128'd147573952589676412928: z <= 7'd67;
            128'd295147905179352825856: z <= 7'd68;
            128'd590295810358705651712: z <= 7'd69;
            128'd1180591620717411303424: z <= 7'd70;
            128'd2361183241434822606848: z <= 7'd71;
            128'd4722366482869645213696: z <= 7'd72;
            128'd9444732965739290427392: z <= 7'd73;
            128'd18889465931478580854784: z <= 7'd74;
            128'd37778931862957161709568: z <= 7'd75;
            128'd75557863725914323419136: z <= 7'd76;
            128'd151115727451828646838272: z <= 7'd77;
            128'd302231454903657293676544: z <= 7'd78;
            128'd604462909807314587353088: z <= 7'd79;
            128'd1208925819614629174706176: z <= 7'd80;
            128'd2417851639229258349412352: z <= 7'd81;
            128'd4835703278458516698824704: z <= 7'd82;
            128'd9671406556917033397649408: z <= 7'd83;
            128'd19342813113834066795298816: z <= 7'd84;
            128'd38685626227668133590597632: z <= 7'd85;
            128'd77371252455336267181195264: z <= 7'd86;
            128'd154742504910672534362390528: z <= 7'd87;
            128'd309485009821345068724781056: z <= 7'd88;
            128'd618970019642690137449562112: z <= 7'd89;
            128'd1237940039285380274899124224: z <= 7'd90;
            128'd2475880078570760549798248448: z <= 7'd91;
            128'd4951760157141521099596496896: z <= 7'd92;
            128'd9903520314283042199192993792: z <= 7'd93;
            128'd19807040628566084398385987584: z <= 7'd94;
            128'd39614081257132168796771975168: z <= 7'd95;
            128'd79228162514264337593543950336: z <= 7'd96;
            128'd158456325028528675187087900672: z <= 7'd97;
            128'd316912650057057350374175801344: z <= 7'd98;
            128'd633825300114114700748351602688: z <= 7'd99;
            128'd1267650600228229401496703205376: z <= 7'd100;
            128'd2535301200456458802993406410752: z <= 7'd101;
            128'd5070602400912917605986812821504: z <= 7'd102;
            128'd10141204801825835211973625643008: z <= 7'd103;
            128'd20282409603651670423947251286016: z <= 7'd104;
            128'd40564819207303340847894502572032: z <= 7'd105;
            128'd81129638414606681695789005144064: z <= 7'd106;
            128'd162259276829213363391578010288128: z <= 7'd107;
            128'd324518553658426726783156020576256: z <= 7'd108;
            128'd649037107316853453566312041152512: z <= 7'd109;
            128'd1298074214633706907132624082305024: z <= 7'd110;
            128'd2596148429267413814265248164610048: z <= 7'd111;
            128'd5192296858534827628530496329220096: z <= 7'd112;
            128'd10384593717069655257060992658440192: z <= 7'd113;
            128'd20769187434139310514121985316880384: z <= 7'd114;
            128'd41538374868278621028243970633760768: z <= 7'd115;
            128'd83076749736557242056487941267521536: z <= 7'd116;
            128'd166153499473114484112975882535043072: z <= 7'd117;
            128'd332306998946228968225951765070086144: z <= 7'd118;
            128'd664613997892457936451903530140172288: z <= 7'd119;
            128'd1329227995784915872903807060280344576: z <= 7'd120;
            128'd2658455991569831745807614120560689152: z <= 7'd121;
            128'd5316911983139663491615228241121378304: z <= 7'd122;
            128'd10633823966279326983230456482242756608: z <= 7'd123;
            128'd21267647932558653966460912964485513216: z <= 7'd124;
            128'd42535295865117307932921825928971026432: z <= 7'd125;
            128'd85070591730234615865843651857942052864: z <= 7'd126;
            128'd170141183460469231731687303715884105728: z <= 7'd127;
            default: z <= 0;
        endcase
    end
endmodule