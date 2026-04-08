# Youtube Summarizer

This project is a small Agentic Workflow that downloads new YouTube videos from a list of channels and/or
a playlist and turns them into one pager text summary and a 2-minute audio brief.

It is implemented as a bash script for MacOS and uses only AI models and tools running locally on Apple Silicon.

# Used AI models / tools

* [parakeet-mlx](https://github.com/senstella/parakeet-mlx) is used to transcribe the videos' audio (speech-to-text)
* [Ollama](https://ollama.com/) is used with [Ministral 3](https://ollama.com/library/ministral-3) to turn 
  transcripts into summaries and the text of audio briefs
* [mlx-audio](https://github.com/Blaizzy/mlx-audio) is used with [Kokoro-82M-bf16](https://github.com/Blaizzy/mlx-audio) 
  to generate audio (text-to-speech)

# Installation / Dependencies

A few things need to be installed on your system:

* yt-dlp (`brew install yt-dlp`) is used to download videos (or rather their audio track)
* uv (`brew install uv`) is used to run the Python code of parakeet-mlx and mlx-audio with 
  the correct Python interpreter version and libraries
* Ollama (`brew install ollama` or download and install the Ollama App for MacOS) is used
  to run the LLMs
* Ministral-3 running in Ollama with a 32k context window (`ollama create ministral-3-32k`; 
  this uses the Modelfile in this repository)
* If you want receive email with the text summary, your `mail` command should be configured;
  instruction on how to configure is with `msmtp` (`brew install msmtp`) later.
* ansifilter (`brew install ansifilter`) is currently required to strip out ANSI Escape codes 
  that Ollama produces in its output; probably can be removed with later version of Ollama
  (see this Github [issue](https://github.com/ollama/ollama/issues/14571) 
  and [PR](https://github.com/ollama/ollama/pull/14670)) 

## Configuration

Copy `config.example.sh` to `config.sh` and set the variables to retrieve multiple channels
(variable `CHANNELS`) and/or one playlist (variable `playlist`). If you want to receive
text summaries via email, set `SEND_EMAIL_TO` to your email address.

Always surround URLs with quotes (`"`) and be sure to keep the formatting for the `CHANNELS``
variables (open and closing parenthes and each URL quoted on a separate line).

## Configuring EMail

The script will use the `mail` command to send email, if the variable SEND_EMAIL_TO is set
in your configuration.  You can configure `mail` to use your email account for sending
emails as follows:

```
brew install msmtp

echo "set sendmail=/opt/homebrew/bin/msmtp" > ~/.mailrc

touch ~/.msmtprc
nano ~/.msmtprc
````

Edit `~/.msmtprc` to configure your email (values may vary check with your provider's docs and your faviorite AI):
```
# Set default values for all following accounts.
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/cert.pem
logfile        ~/.msmtp.log

# Your Account
account        <any name>
host           <your mail server, e.g., mail.gmx.net>
port           <port; usually 587>
from           <your email address>
user           <usually your email address; can be different for some providers>
password       <your email password>
tls_starttls   on

# Set a default account
account default : <name from above>
```




