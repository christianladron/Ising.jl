from OpenGL.GL import *
from OpenGL.GLUT import *
from OpenGL.GLU import *
import pylab as pyl
from PIL import Image
import ImageOps

ESCAPE = '\033'

window = 0

#rotation
X_AXIS = 0.0
Y_AXIS = 45.0
Z_AXIS = 0.0
giroprueba = 0
archivo = open("pruebasAnima.dat","r")
frame_number=1

DIRECTION = 1


def InitGL(Width, Height):

        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClearDepth(1.0)
        glDepthFunc(GL_LESS)
        glEnable(GL_DEPTH_TEST)
        glShadeModel(GL_SMOOTH)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        gluPerspective(45.0, float(Width)/float(Height), 0.1, 100.0)
        glMatrixMode(GL_MODELVIEW)

def keyPressed(*args):
        if args[0] == ESCAPE:
                sys.exit()


def DrawGLScene():
        global X_AXIS,Y_AXIS,Z_AXIS,giroprueba,caras,frame_number
        global DIRECTION

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);

        glLoadIdentity()
        glTranslatef(0.0,0.0,-6.0)

        glRotatef(Y_AXIS,0.0,1.0,0.0)
        #glRotatef(X_AXIS,1.0,0.0,0.0)
        #glRotatef(Z_AXIS,0.0,0.0,1.0)
        glRotatef(30,1.0,0.0,1.0)
        linea = archivo.readline()
        if linea!="":
            caras = pyl.array(eval(linea)).reshape((17,17,17))
        #else:
            #raise KeyError
        # Draw Cube (multiple quads)
        lado = 2.0/17
        glBegin(GL_QUADS)
        for i in range(0,17):
            for j in range(0,17):
                for k in range(0,17):
                    opacidad = (caras[i][j][k]+1.07)/2.07
            #lado arriba
                    glColor4f(0.0,1.0,0.0,opacidad)
                    glVertex3f( 1.0-i*lado, (k+1)*lado-1,-1.0+j*lado)
                    glVertex3f(1-(i+1)*lado, (k+1)*lado-1,-1.0+j*lado)
                    glVertex3f(1-(i+1)*lado, (k+1)*lado-1, -1.0+(j+1)*lado)
                    glVertex3f( 1.0-i*lado, (k+1)*lado-1, -1.0+(j+1)*lado)
            #Lado derecho
                    glColor4f(0.0,0.0,1.0,opacidad)
                    glVertex3f( 1.0-i*lado, -1.0+(k+1)*lado, (j+1)*lado-1.0)
                    glVertex3f(1.0-(i+1)*lado, -1.0+(k+1)*lado, (j+1)*lado-1.0)
                    glVertex3f(1.0-(i+1)*lado,-1.0+k*lado, (j+1)*lado-1.0)
                    glVertex3f( 1.0-i*lado,-1.0+k*lado, (j+1)*lado-1.0)
            #Lado izquierdo
                    glColor4f(1.0,0.0,0.0,opacidad)
                    glVertex3f(1.0-(i+1)*lado,-1.0+(k+1)*lado,-1.0+(j+1)*lado)
                    glVertex3f(1.0-(i+1)*lado,-1.0+(k+1)*lado,-1.0+j*lado)
                    glVertex3f(1.0-(i+1)*lado,-1.0+k*lado,-1.0+j*lado)
                    glVertex3f(1.0-(i+1)*lado,-1.0+k*lado,-1.0+(j+1)*lado)


                    #glColor3f(1.0,0.0,0.0)
                    #glVertex3f( 1.0,-1.0, 1.0)
                    #glVertex3f(-1.0,-1.0, 1.0)
                    #glVertex3f(-1.0,-1.0,-1.0)
                    #glVertex3f( 1.0,-1.0,-1.0)

                    #glColor3f(1.0,1.0,0.0)
                    #glVertex3f( 1.0,-1.0,-1.0)
                    #glVertex3f(-1.0,-1.0,-1.0)
                    #glVertex3f(-1.0, 1.0,-1.0)
                    #glVertex3f( 1.0, 1.0,-1.0)

                    #glColor3f(1.0,0.0,1.0)
                    #glVertex3f( 1.0, 1.0,-1.0)
                    #glVertex3f( 1.0, 1.0, 1.0)
                    #glVertex3f( 1.0,-1.0, 1.0)
                    #glVertex3f( 1.0,-1.0,-1.0)

        glEnd()


        #X_AXIS = X_AXIS - 0.30
        #Z_AXIS = Z_AXIS - 0.30
        #Y_AXIS = Y_AXIS - 0.30
        giroprueba+=1
        buf = glReadPixels(0,0,640,480,GL_RGB,GL_BYTE)
        img = Image.frombuffer('RGB',(640,480),buf)
        img.save('./imagenesVideo/frame%06i.png'%(frame_number), quality=100, optimize=True, progressive=True)
        frame_number+=1
        glutSwapBuffers()



def main():

        global window

        glutInit(sys.argv)
        glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
        glutInitWindowSize(640,480)
        glutInitWindowPosition(200,200)

        window = glutCreateWindow('OpenGL Python Cube')

        glutDisplayFunc(DrawGLScene)
        glutIdleFunc(DrawGLScene)
        glutKeyboardFunc(keyPressed)
        InitGL(640, 480)
        glutMainLoop()

if __name__ == "__main__":
        main()
