#!/usr/bin/python3

import asyncore
import email
import os
import smail
import smtpd
import smtplib
import sys
import time

logfilename = "/data/logs/mail.log"
logfile=sys.stdout

def log(*args):
    print(time.strftime('%F %T'), *args, file=logfile)

# based on https://stackoverflow.com/a/2691249
class EmlServer(smtpd.SMTPServer):
    def process_message(self, peer, sender, receivers, data, **kwargs):
        global logfile
        with open(logfilename, "a", 1) as logfile:
            log('received message', peer, sender, receivers, kwargs)
            message = email.message_from_bytes(data)

            # sign message
            key_signer = '/data/keys/%s.key' % sender
            cert_signer = '/data/certs/%s.crt' % sender
            if os.path.isfile(key_signer) and os.path.isfile(cert_signer):
                log('sign message', key_signer, cert_signer, 'additional_certs')
                try:
                    message = smail.sign_message(message, key_signer, cert_signer, additional_certs=['/data/certs/intermediate.crt', '/data/certs/root.crt'])
                except:
                    import traceback
                    traceback.print_exc(file=logfile)
                    return '554 exception when signing'

            # send message
            mx_server = 'gmail-smtp-in.l.google.com'
            # mx_server = 'aspmx.l.google.com'
            try:
                with smtplib.SMTP(mx_server, 25, 'shpakovsky.ru') as server:
                    server.starttls()
                    #server.send_message(message, sender, receivers)
                    result = server.sendmail(sender, receivers, message.as_string())
                    log('sent', result)
            except:
                import traceback
                traceback.print_exc(file=logfile)
                return '554 exception when sending'


def run():
    global logfile
    with open(logfilename, "a") as logfile:
        log('staring')
    # start the smtp server on *:1025
    foo = EmlServer(('0.0.0.0', 1025), None)
    try:
        asyncore.loop()
    except KeyboardInterrupt:
        pass
    with open(logfilename, "a") as logfile:
        log('exiting')


if __name__ == '__main__':
    run()

