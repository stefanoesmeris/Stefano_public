# -*- coding: utf-8 -*- 

###########################################################################
## Python code generated with wxFormBuilder (version Jun 17 2015)
## http://www.wxformbuilder.org/
##
## PLEASE DO "NOT" EDIT THIS FILE!
###########################################################################

import wx
import wx.xrc

MINHA_STRING = ''

###########################################################################
## Class MyFrame1
###########################################################################

class MyFrame1 ( wx.Frame ):
	
	def __init__( self, parent ):
		wx.Frame.__init__ ( self, parent, id = wx.ID_ANY, title = wx.EmptyString, pos = wx.DefaultPosition, size = wx.Size( 500,300 ), style = wx.DEFAULT_FRAME_STYLE|wx.TAB_TRAVERSAL )
		
		self.SetSizeHints( wx.DefaultSize, wx.DefaultSize )
		
		bSizer1 = wx.BoxSizer( wx.VERTICAL )
		
		self.m_staticText1 = wx.StaticText( self, wx.ID_ANY, u"Digite o Valor", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText1.Wrap( -1 )
		bSizer1.Add( self.m_staticText1, 0, wx.ALL, 5 )
		
		self.m_textCtrl1 = wx.TextCtrl( self, wx.ID_ANY, u"", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_textCtrl1.SetToolTip( u"digite um valor de 0 a dez" )
		self.m_textCtrl1.SetValue(MINHA_STRING)
		
		bSizer1.Add( self.m_textCtrl1, 0, wx.ALL, 5 )
		
		self.m_button1 = wx.Button( self, wx.ID_ANY, u"&OK", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_button1.Enable( False )
		
		bSizer1.Add( self.m_button1, 0, wx.ALL, 5 )
		
		
		self.SetSizer( bSizer1 )
		self.Layout()
		
		self.Centre( wx.BOTH )
		
		# Connect Events
		self.m_textCtrl1.Bind( wx.EVT_TEXT, self.m_textCtrl1OnText )
		self.m_button1.Bind( wx.EVT_BUTTON, self.m_button1OnButtonClick )
	
	def __del__( self ):
		pass
	
	
	# Virtual event handlers, overide them in your derived class
	def m_textCtrl1OnText( self, event ):
		c = self.m_textCtrl1.GetValue()
		if c.isdigit():
			self.m_button1.Enable(True)
		event.Skip()
	
	def m_button1OnButtonClick( self, event ):
		self.dialog = MyDialog1(self)
		self.dialog.Show()
		event.Skip()
	
	def m_buttonClick( self, event):
		event.Skip()

###########################################################################
## Class MyDialog1
###########################################################################

class MyDialog1 ( wx.Dialog ):
	
	def __init__( self, parent ):
		wx.Dialog.__init__ ( self, parent, id = wx.ID_ANY, title = wx.EmptyString, pos = wx.DefaultPosition, size = wx.Size( 529,303 ), style = wx.DEFAULT_DIALOG_STYLE )
		
		self.SetSizeHints( wx.DefaultSize, wx.DefaultSize )
		
		bSizer2 = wx.BoxSizer( wx.VERTICAL )
		
		self.m_staticText2 = wx.StaticText( self, wx.ID_ANY, u"MyLabel", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText2.Wrap( -1 )
		bSizer2.Add( self.m_staticText2, 0, wx.ALL, 5 )
		
		self.m_textCtrl2 = wx.TextCtrl( self, wx.ID_ANY, wx.EmptyString, wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer2.Add( self.m_textCtrl2, 0, wx.ALL, 5 )
		
		self.m_button2 = wx.Button( self, wx.ID_ANY, u"MyButton", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer2.Add( self.m_button2, 0, wx.ALL, 5 )
		
		
		self.SetSizer( bSizer2 )
		self.Layout()
		
		self.Centre( wx.BOTH )
		
		# Connect Events
		#self.m_textCtrl2.Bind( wx.EVT_TEXT, self.m_textCtrl2OnText )
		self.m_button2.Bind( wx.EVT_BUTTON, self.m_button2OnButtonClick )
		
	
	def __del__( self ):
		pass
	
	
	# Virtual event handlers, overide them in your derived class
	def m_textCtrl2OnText( self, event ):
		event.Skip()
	
	def m_button2OnButtonClick( self, event ):
		MINHA_STRING = self.m_textCtrl2.GetValue()
		self.Close()
		event.Skip()
		
	
		

class MyApp(wx.App):
	def OnInit(self):
		self.main = MyFrame1(None)
		self.SetTopWindow(self.main)
		self.main.Show()
		self.Bind ( wx.EVT_BUTTON, self.m_buttonClick )
		return True
		
	def m_buttonClick( self, event):
		event_id = event.GetId()
		if event_id == self.main.dialog.m_button2.GetId():
			x = self.main.dialog.m_textCtrl2.GetValue()
			self.main.m_staticText1.SetLabel(x)
			self.main.dialog.Destroy()
		else:
			print('outro evento de Botao')
		
# segue aqui um comentario para verificar o funcionamento do github
		
if __name__ == "__main__":
	app = MyApp(False)
	app.MainLoop()
