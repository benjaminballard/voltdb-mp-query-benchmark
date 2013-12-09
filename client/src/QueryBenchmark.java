/* This file is part of VoltDB.
 * Copyright (C) 2008-2013 VoltDB Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with VoltDB.  If not, see <http://www.gnu.org/licenses/>.
 */

package client;

import java.util.Random;
import java.math.BigDecimal;
import java.math.MathContext;
import org.voltdb.types.TimestampType;

public class QueryBenchmark extends BaseBenchmark {

    private Random rand = new Random();

    private String queryName;
    private int advertisers = 1000;

    // constructor
    public QueryBenchmark(BenchmarkConfig config) {
        super(config);
        
        // set any instance attributes here
        queryName = config.queryname;
    }

    public void initialize() throws Exception {
        // get count of advertisers loaded
        advertisers = client.callProcedure("SELECT COUNT(*) FROM advertisers;").getResults()[0].asScalarLong();
    }

    public void iterate() throws Exception {
        // query
        client.callProcedure(new BenchmarkCallback(queryName),
                             queryName,
                             rand.nextInt(advertisers)+1
                             );

    }

    public void printResults() throws Exception {
        
        System.out.print("\n" + HORIZONTAL_RULE);
        System.out.println(" Transaction Results");
        System.out.println(HORIZONTAL_RULE);
        BenchmarkCallback.printProcedureResults(queryName);

        super.printResults();
    }
    
    public static void main(String[] args) throws Exception {
        BenchmarkConfig config = BenchmarkConfig.getConfig("QueryBenchmark",args);
        
        BaseBenchmark benchmark = new QueryBenchmark(config);
        benchmark.runBenchmark();
    }
}
