<template>
  <div class="flex flex-row">
        <div class="">
        <textfield class="mx-2" title="Destination IP" v-model="destIP"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="wildcardDIP"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Source IP" v-model="sourceIP"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="wildcardSIP"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Destination Port" v-model="destPort"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="wildcardDPort"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Source Port" v-model="sourcePort"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="wildcardSPort"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Protocol" v-model="proto"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="wildcardProto"/>
    </div>
    <div class="my-auto mx-4">
        <button type="button" @click="saveRule" class="rounded bg-white/10 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-white/20">Save</button>
        <button type="button" @click="loadInitialState" class="rounded bg-white/10 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-white/20">Load</button>
    </div>
  </div>
</template>

<script>
import Checkbox from './Checkbox.vue'
import Textfield from './Textfield.vue'
export default {
  components: { Textfield, Checkbox },
  props: {
    index : Number,
    initialRule: String
  },
  data: () => {
    return {
        destIP: "",
        sourceIP: "",
        destPort: "",
        sourcePort: "",
        proto: "",
        wildcardDIP: false,
        wildcardSIP: false,
        wildcardDPort: false,
        wildcardSPort: false,
        wildcardProto: false,
    }
  },
  
  methods: {
    loadInitialState() {
        // location | wildcard | destIP[4] | sourceIP[4] | destPort[2] | sourcePort[2] | protocol
        // 00       | 06       | 0A140178  | 0A00009F   | 0000       | 0000        | 06

        this.destIP = this.cvtRawToIP(this.initialRule.slice(4, 12));
        this.sourceIP = this.cvtRawToIP(this.initialRule.slice(12, 20));
        this.destPort = this.cvtRawToPort(this.initialRule.slice(20, 24));
        this.sourcePort = this.cvtRawToPort(this.initialRule.slice(24, 28));
        this.proto = this.cvtRawToByte(this.initialRule.slice(28, 30));

        this.wildcardDIP = (parseInt(this.initialRule.slice(2, 4), 16) & 2**4) != 0;
        this.wildcardSIP = (parseInt(this.initialRule.slice(2, 4), 16) & 2**3) != 0;
        this.wildcardDPort = (parseInt(this.initialRule.slice(2, 4), 16) & 2**2) != 0;
        this.wildcardSPort = (parseInt(this.initialRule.slice(2, 4), 16) & 2**1) != 0;
        this.wildcardProto = (parseInt(this.initialRule.slice(2, 4), 16) & 2**0) != 0;

    },
    cvtRawToIP(input) {
        // get every 2 characters
        var octets = input.match(/.{1,2}/g);

        if (octets.length != 4) {
            return "";
        }

        // Convert to decimal
        var decOctets = octets.map((octet) => {
            return parseInt(octet, 16);
        });

        return decOctets.join(".");
    },
    cvtRawToPort(input) {
        if (input == "0000") {
            return "";
        }
        return parseInt(input, 16);
    },
    cvtRawToByte(input) {
        if (input == "00") {
            return "0";
        }
        return parseInt(input, 16);
    },
    cvtIPtoRaw(input) {
        var octets = input.split(".");

        if (octets.length != 4) {
            return "00000000";
        }

        // Convert to hex
        var hexOctets = octets.map((octet) => {
            return parseInt(octet).toString(16).padStart(2, '0').toUpperCase();
        });

        return hexOctets.join("");
    },
    cvtPortToRaw(input) {
        if (input == "") {
            return "0000";
        }
        return parseInt(input).toString(16).padStart(4, '0').toUpperCase();
    },
    cvtByteToRaw(input) {
        if (input == "") {
            return "00";
        }
        return parseInt(input).toString(16).padStart(2, '0').toUpperCase();
    },
    saveRule() {

        var wild = 0;
        wild |= this.wildcardDIP ? 2**4 : 0;
        wild |= this.wildcardSIP ? 2**3 : 0;
        wild |= this.wildcardDPort ? 2**2 : 0;
        wild |= this.wildcardSPort ? 2**1 : 0;
        wild |= this.wildcardProto ? 2**0 : 0;

        var dip = this.cvtIPtoRaw(this.destIP)
        var sip = this.cvtIPtoRaw(this.sourceIP)
        var dport = this.cvtPortToRaw(this.destPort)
        var sport = this.cvtPortToRaw(this.sourcePort)
        var proto = this.cvtByteToRaw(this.proto)

        // location | wildcard | destIP[4] | sourceIP[4] | destPort[2] | sourcePort[2] | protocol
        var raw = `payload=${this.index.toString().padStart(2, '0')}${this.cvtByteToRaw(wild)}${dip}${sip}${dport}${sport}${proto}`;

        console.log("Raw rule: ", raw);

        // Use fetch API over axios as built in 
        fetch('/api/firewall', {
            method: 'POST',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: raw
        }).then((response) => {
            console.log("Response: ", response);
        }).catch((error) => {
            console.log("Error: ", error);
        });
   

    }
  }

}
</script>

<style>

</style>