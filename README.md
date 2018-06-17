# Foreword

This container can be used to run a Waves platform node, either on testnet or mainnet. You can it use to start tinkering with the Waves platform and easily get started. However the main use cases are:
1. You are a developer that needs to interact with the Waves API, you want a local node to run your tests to cut down on network latency;
2. You are a node owner and you want to streamline maintaining and upgrading your node.

If you simply start the container as-is you will get a node with the out of the box configuration running on testnet. Please be advised that probably you should take some steps to ensure the reliability and security of your node. Never, but never, expose your node on the Internet without customizing the configuration. You should:
* map `/var/lib/waves` to have the blockchain and the node status stored in a non volatile volume;
* map `/etc/waves/waves.conf` to start with your own configuration.
 
More details below.

# Editing waves.conf

For any serious use of the node you will need to edit waves.conf. Start with building the container image and extracting the file from it. In the folder where you downloaded your Dockerfile run:

    docker build -t wavesnode:latest .
    docker cp $(docker create wavesnode:latest):/etc/waves/waves.conf waves.conf
	
The official Waves documentation provides lenghty instructions on [how to configure a node](https://docs.wavesplatform.com/waves-full-node/how-to-configure-a-node.html "how to configure a node") and edit waves.conf and make it fit your needs. You will want to:
 * decide if you want to run a testnet or mainnet node;
 * enable the REST API;
 * provide a personalized and secret API key;
 * add your wallet.

When starting your container you can map your modified `waves.conf` and the node will start with your configuration.

# Jumpstarting the blockchain

Immediately upon being started the Waves node will download the genesis block and then proceed to download the whole blockchain. This is a long process, and will take to several hours. So you want to be able to persist your node's state every time you restart.

Create a folder on your Docker host to map into the container, the instructions that follow imply that you've done just that. For experienced Docker users, you can also use a Docker volume.

To jumpstart the blockchain you can download a binary file and import it into your node. Start the container with a different entrypoint so you can execute the necessary actions before starting the node.

    docker run -it --entrypoint /bin/bash -v /waves/data/folder:/var/lib/waves -v waves.conf:/etc/waves wavesnode:latest

You will be dropped into a command line, download the [latest prebuilt blockchain binay file](http://blockchain.wavesnodes.com "latest prebuilt blockchain binay file"):

	curl -s -L -o /var/lib/waves/blockchain-binary http://blockchain.wavesnodes.com/mainnet-0.13.3-1036741

And then clean your data folder and import the binary data:

    rm -rf /var/lib/waves/data
    importer /etc/waves/waves.conf /var/lib/waves/blockchain-binary

After a sucessful import you will want to remove the binary file.

# Starting your node

You're ready to start your node, this will probably be a trial and error process. So don't worry if something goes wrong on the first try. You will probably need to tweak your waves.conf or fix a file path.

When starting the node we will expose all the necessary ports and map the necessary files into the running container:

    docker run -it --log-driver json-file --log-opt max-size=500m -v /waves/data/folder:/var/lib/waves -v waves.conf:/etc/waves -p 6868:6868 -p 6886:6886 -p 127.0.0.1:6869:6869 wavesnode:latest
	
The flag `-it` starts the container in interactive mode, you will see the output the node startup. Something like:

    2018-06-16 13:17:47,714 INFO  [main] c.w.Application$ - Starting...
    2018-06-16 13:17:48,310 INFO  [main] kamon.Kamon$Instance - Initializing Kamon...
    2018-06-16 13:17:48,605 INFO  [ctor.default-dispatcher-3] a.event.slf4j.Slf4jLogger - Slf4jLogger started
    2018-06-16 13:17:48,731 INFO  [ctor.default-dispatcher-2] a.event.slf4j.Slf4jLogger - Slf4jLogger started
    2018-06-16 13:17:48,737 INFO  [main] c.w.Application$ - Waves v0.13.3 Blockchain Id: W
    2018-06-16 13:17:53,325 INFO  [main] c.w.n.PeerDatabaseImpl - Loaded 135 known peer(s) from peers.dat
    2018-06-16 13:17:56,293 INFO  [main] c.w.Application - REST API was bound on 0.0.0.0:6869

After that you should have messages like:

    2018-06-16 13:18:01,520 INFO  [appender-47] c.w.s.BlockchainUpdaterImpl - New height: 1044025
	
That means your node is up and running and downloading blocks that haven't been imported from the blockchain binary file.

# Interacting with your node

If you've enable the REST API in `waves.conf` and you exposed the necessary port as per the exameple above, you will be able to interact with your node from the Docker host. For instance you can get your node status:

    curl -X GET --header 'Accept: application/json' 'http://localhost:6869/node/status'
	
If you're running Docker machine with a graphical user interface or you set up a SSH tunnel you can user your web browser to access the [Swagger UI](http://localhost:6869/api-docs/index.htm "Swagger UI").

