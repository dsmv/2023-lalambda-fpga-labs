
#include <cstdint>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/select.h>
#include <errno.h>
#include <termio.h>


int  _uart_fd;
char _uart_name[128];

void init( char *name ) 
{
    strncpy( _uart_name, name, 256 ); _uart_name[255]=0;

    printf( "open uart: %s\n", _uart_name );
    _uart_fd = open( _uart_name, O_RDWR | O_NONBLOCK );

    printf( "_uart_fd=%d\n", _uart_fd );

    struct termios tty;        

    if(tcgetattr(_uart_fd, &tty) != 0) 
    {
        printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
    }   

    tty.c_cflag &= ~CRTSCTS; // Disable RTS/CTS hardware flow control (most common)
    tty.c_cflag |= CREAD | CLOCAL; // Turn on READ & ignore ctrl lines (CLOCAL = 1)
    tty.c_lflag &= ~ICANON;
    tty.c_lflag &= ~ECHO; // Disable echo
    tty.c_lflag &= ~ECHOE; // Disable erasure
    tty.c_lflag &= ~ECHONL; // Disable new-line echo
    tty.c_lflag &= ~ISIG; // Disable interpretation of INTR, QUIT and SUSP
    tty.c_iflag &= ~(IXON | IXOFF | IXANY); // Turn off s/w flow ctrl
    tty.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL); // Disable any special handling of received bytes
    tty.c_oflag &= ~OPOST; // Prevent special interpretation of output bytes (e.g. newline chars)
    tty.c_oflag &= ~ONLCR; // Prevent conversion of newline to carriage return/line feed
    tty.c_cc[VTIME] = 0;    // Wait for up to 1s (10 deciseconds), returning as soon as any data is received.
    tty.c_cc[VMIN] = 0;
    tty.c_cflag &= ~CSIZE; // Clear all the size bits, then use one of the statements below
    
    tty.c_cflag |= CS8; // 8 bits per byte (most common)
    tty.c_cflag &= ~CSTOPB; // Clear stop field, only one stop bit used in communication (most common)
    tty.c_cflag &= ~PARENB; // Clear parity bit, disabling parity (most common)


    cfsetispeed(&tty, B115200);
    cfsetospeed(&tty, B115200);
    
}

int read_uart( uint8_t *buf, int size )
{
    int curr_size=size;
    uint8_t *ptr=buf;


    for( ; ; )
    {
        int sz = read( _uart_fd, ptr, curr_size );            
        if( sz<0 )
            sz=0;
        if( sz>0 )
        {
            curr_size-=sz;
            ptr+=sz;

            if( 1==size )
                printf( "%02X \r", buf[0] & 0xFF );

            if( 0==curr_size )
                break;
        }

    }
    return 1;
}

int main( int argc, char** argv )
{

    char *name = "/dev/ttyUSB0";
    if( argc>=2 )
        name = argv[1];

    init( name );


    int state=1;

    uint8_t buf_sync[3];
    uint8_t buf_data[2048*3];

    for( ; ; )
    {
        switch( state )
        {
            case 1:
            {
                read_uart( &buf_sync[0], 1 );
                if( 0xAA==buf_sync[0] )
                {
                    state=2;
                    printf( "sync0 - done\n");
                }
            }
            break;

            case 2:
            {
                read_uart( &buf_sync[1], 1 );
                if( 0xBB==buf_sync[1] )
                {
                    state=3;
                    printf( "sync1 - done\n");
                } else
                {
                    state = 1;
                }
            }
            break;

            case 3:
            {
                read_uart( &buf_sync[2], 1 );
                if( 0xCC==buf_sync[2] )
                {
                    state=4;
                    printf( "sync2 - done\n");
                }else
                {
                    state = 1;
                }
            }
            break;

            case 4:
            {
                read_uart( &buf_data[0], 2048*3 );
                printf( "read_data - done\n");
                state=5;
            }
            break;

            case 5:
            {
                FILE *fo = fopen( "data.txt", "wt");
                FILE *fb = fopen( "data.bin", "wb");
                int val;
                int v0;
                int v1;
                int v2;
                uint8_t *src=buf_data;
                for( int ii=0; ii<2048; ii++ )
                {
                    v0 = *src++ & 0xFF;
                    v1 = *src++ & 0xFF;
                    v2 = *src++ & 0xFF;

                    val = (v2<<16) | (v1<<8) | (v0);
                    if( val & 0x00800000 )
                        val |= 0xFF000000;

                    fprintf( fo, " %d\n", val );

                    fwrite( &v0, 1, 1, fb );
                    fwrite( &v1, 1, 1, fb );
                    fwrite( &v2, 1, 1, fb );

                    if( ii<16 )
                        printf( "%d\n", val );

                }
                fclose( fo );
                fclose( fb );

                state = 6;
            }
            break;
        }

        if( 6==state )
            break;
    }

    return 0;
}

