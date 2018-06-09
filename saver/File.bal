import ballerina/io;
import ballerina/log;

//Given a bytte channel, save it to a user given location.
function save(string fileName, io:ByteChannel byteChannel) {
    io:ByteChannel destinationChannel = getFileChannel(fileName, io:WRITE);
    try {
        copy(byteChannel, destinationChannel);
        log:printInfo("File Received");
    } catch (error err) {
        log:printError("error occurred while saving file : "
                + err.message);
    } finally {
        byteChannel.close() but {
            error e => log:printError("Error closing byteChannel ",
                err = e)
        };
        destinationChannel.close() but {
            error e =>
            log:printError("Error closing destinationChannel",
                err = e)
        };
    }
}

function getFileChannel(string filePath, io:Mode permission)
             returns (io:ByteChannel) {
    io:ByteChannel channel = io:openFile(filePath, permission);
    return channel;
}

function readBytes(io:ByteChannel channel, int numberOfBytes)
             returns (blob, int) {
    var result = channel.read(numberOfBytes);
    match result {
        (blob, int) content => {
            return content;
        }
        error readError => {
            throw readError;
        }
    }
}
function writeBytes(io:ByteChannel channel, blob content, int startOffset = 0)
             returns (int) {
    var result = channel.write(content, startOffset);
    match result {
        int numberOfBytesWritten => {
            return numberOfBytesWritten;
        }
        error err => {
            throw err;
        }
    }
}
function copy(io:ByteChannel src, io:ByteChannel dst) {
    int bytesChunk = 10000;
    int numberOfBytesWritten = 0;
    int readCount = 0;
    int offset = 0;
    blob readContent;
    boolean doneCoping = false;
    try {
        while (!doneCoping) {
            (readContent, readCount) = readBytes(src, 1000);
            if (readCount <= 0) {
                doneCoping = true;
            }
            numberOfBytesWritten = writeBytes(dst, readContent);
        }
    } catch (error err) {
        throw err;
    }
}
